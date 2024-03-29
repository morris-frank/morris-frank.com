+++
title = "WaveNet from scratch"
tags = ["Machine Learning"]
date = "2019-12-02"
tldr = "Today we are building a WaveNet from scratch. The WaveNet is an autoregressive, generative and deep model for audio signals."
+++

_This guide is geared towards readers with a background in modern
deep learning._

### The problem

Lets say we want to generate sound signals. This might happen in different
settings. We might have music notes + a instrument and want to generate
their sound \\(w(\mathrm{note}, \mathrm{instrument}) = \mathrm{sound}\\), or we
have a text and want to generate the corresponding speech
\\(w(\mathrm{text}) = \mathrm{sound}\\) or maybe we already have a sound signal,
but it is noisy and we want to remove the noise \\(w(\mathrm{noisy\ sound}) = \mathrm{sound}\\).

For all of these we need to find a model \\(w(\cdot)\\) which can generate
high-quality semantic sounds.

Sound is just a 1-dimensional temporal signal. Therefore the same methods
can be used for other similar signals like [EEG](https://w.wiki/DHK)
or financial data. I will ignore those areas here but you can find cool
applications in other literature.

### Using Waveforms

Sounds are vibrations of air, increase and decrease of air pressure over time.
As such sound, measured at one given point, is a 1D-signal over time. Stereo
sound recordings (over more than that) are multiple such signals, from different
spatial positions. When we are working with sound digitally we need an
approximation of those recorded analog signals. The simplest digitalization is
[Pulse-code modulation](https://w.wiki/DHJ) (PCM). In PCM we take
samples from the analog signal and discretize them at fixed same-length
intervals. E.g. with 8kHz 16bit PCM that means that we take a sample from the
vibration every \\(\frac{1}{8000}\mathrm{sec}\\) and choose the closest of
\\(2^{16}=65536\\) bins/amplitude values. Below we have a small excerpt of a sound
file encoded with 16kHz 16bit.

![A cut from an audio waveform.](wave.jpg)

As we have here a sample length of 100 at a sample rate of 16kHz this sample is
_only_ 6.25 ms long. Directly we see the problem in working with music in
the time-domain: Interesting information is at completely different temporal
scales. On the low level, we have the characteristics of different notes, e.g.
a piano has frequencies between around 30 Hz to 4 kHz, on top of you could
expect modulating effects (e.g a voice vibrato is around 6Hz), growing larger in
the temporal dependencies, a short rhythm in the range of seconds to the
structure of songs/works at multiple minutes. How can we capture all those
scales with one model?

The general idea of the WaveNet [[1]](#oordWaveNet2016) to have a _causal_ generation process.
This means that each predicted output value is only based on information of
previous input values, given an ordering. Now the idea of this causal
autoregressive process comes from previous works by the same authors (and other)
PixelRNN [[2]](#oordPixelRNN2016), and incorporating convolutions
into the same process in PixelCNN [[3]](#oordPixelCNN2016). In those
they also used the same principle to generate images, quite successfully.
They took this approach to sound, as sound, in contrast to images, actually has
a natural 1D-ordering.

For the WaveNet the input is assumed to be as long as the output that we want to
generate. For now let us assume we have a sound to sound translation task, so that
the input and output are of the same type (Mono-audio).

<figure>
    <svg id="figcausal_svg" height="300" width="600">
        Sorry, your browser does not support inline SVG.
    </svg>
    <script type="text/javascript" src="causal.js" defer></script>
</figure>

### Dilated Convolutions

<figure>
    <svg id="figdilated_svg" height="300" width="600">
        Sorry, your browser does not support inline SVG.
    </svg>
    <script type="text/javascript" src="dilated.js" defer></script>
</figure>

Do make the dilated convolutions we are doing the dilation and the convolution
separately. Looking back to the animation above, we see that for the dilation in
the first hidden layer the convolution we kind of have two _dense_
convolutions (with the same kernel), for the even and the odd elements. In the
implementation we can achieve that by splitting up the input along its time axis
and transposing as such that these blocks go into the batch-size dimension.

In PyTorch we always have the dimensions ordering \\(\mathrm{batch\\_size} \times \mathrm{channels} \times \mathrm{length}\\).

So for an input of the size \\(4\times 1\times 128\\) with a dilation of \\(2\\) we
end up with \\(8\times 1\times 64\\). Or a direct example (\\(2\times 1\times 4\\)):

\\[
\begin{align}x &= \begin{bmatrix}0 & 1 & 2 & 3\\\\A & B & C & D\end{bmatrix}\\\\&\Rightarrow\\\\dilate(x, 2) &= \begin{bmatrix}0 & 2\\\\A & C\\\\1 & 3\\\\B & D\end{bmatrix}\end{align}
\\]

Of course now we have the difficulty that our batch dimension is cluttered with
all blocks from the different samples in the mini-batch. Therefore we always
need to keep track of the dilation we are having right now, so that we can
reverse it. In code this gives us:


```py3
def dilate(x: torch.Tensor, new: int, old: int = 1) -> torch.Tensor:
    """
    :param x: The input Tensor
    :param new: The new dilation we want
    :param old: The dilation x already has
    """
    [N, C, L] = x.shape  # N == Batch size × old
    if (dilation := new / old) == 1:
        return x
    L, N = int(L / dilation), int(N * dilation)
    x = x.permute(1, 2, 0)
    x = torch.reshape(x, [C, L, N])
    x = x.permute(2, 0, 1)
    return x.contiguous()
```

Now that we dilated we can apply a normal 1-dim convolution on the new Tensor
which will go along the time axis and thus have a dilated receptive field. For
the animations given above we would dilate three times each with a factor of two
(\\(2, 4, 8\\)).

_As a sidenote: This is different from the dilated (à trous) convolution as
    implemented in PyTorch's `nn.Conv1d` itself._

### Gates, Residuals and Skips

The different hidden layers in the model have differently sized receptive fields
(play around with the animation to see this). We introduced the problem of
time-domain modeling as a problem of different temporal scales. Now these
different layers, so the assumption, will look at features at different scales,
combining the information from more low-level features. As the inference process
needs the information from all those levels, the model employs skip-connections.
Instead of taking the output of the last layer the actual model output is the
sum of projections out of all the layers.

Next we see that not all information flowing upwards from the low-level to the
high level is useful information to keep, especially with the big temporal
receptive field the flow of information needs to be regulated. Here he authors
take the idea of gated convolutions as it is known from e.g. LSTM
[[5]](#hochreiterLong1997). For each hidden layer we have have two
convolutions followed by a `sigmoid` \\(\sigma\\) and a `tanh`,
respectively. The `sigmoid` gives a scaling in \\([0, 1]\\) and is
acting as the gate (the value is the amount of allowed information to flow).
The `tanh` gives a scaling of \\([-1,1]\\) and is acting as the feature
magnitude. Their outputs are just multiplied, to <i>apply the gating</i>. Keep
in mind though that this does not necessarily accurately predict the trained
behavior, but it has shown better training performance in comparable settings.

Further all hidden layers are constructed as residuals, the to the convolution
is added back to the output of the convolutions. Residual learning ensures that
the zero-centered initialization of the weights constructs an identity mapping,
meaning if the layer does not learn anything it also does not degrade the
inference in any way [[6]](#heDeep2015). For deeper models this has
shown to considerably improves training speed.

To summarize the construction of one hidden layer: The output of the previous
layer gets dilated, we keep this as the reference, goes through the gated
convolution giving the residual. The residual is then added to the
skip-connection flow and the reference as the input for the next hidden
layer.

In a picture:

<figure>
    <img src="wavenet_dilated_block.svg" alt="Schematic figure showing the flow of information through one of the dilated blocks in a WaveNet.">
</figure>

Why the \\(1\times 1\\) convolutions after the residual? The width (channels) of
the residual, skip and reference might be different. Therefore we need to learn
a mapping channels to channels, which is precisely a \\(1\times 1\\) convolution.

Setting the forward pass of one hidden layer in code we will get something
along:

```py3
dilated = dilate(feat, new=new_dilation, old=old_dilation)

filters = torch.sigmoid(filter_conv(dilated))
gates = torch.tanh(gate_conv(dilated))
residual = filters * gates

feat = dilated + feat_conv(residual)
skip = skip + skip_conv(residual)
```

### Putting it together

The previous section defines the flow for one <i>layer</i> (as in the dilated
layer in the animation from the beginning). We want to put multiple such layers
together to get the large dilation that we want. As in the original work we use
multiple blocks where one block is as in our visualization. So if we want to
compute the compound receptive field size of the complete model we have:

\\[
\mathrm{receptivefield} = n_{\mathrm{blocks}} \cdot \prod_{i=0}^{n_{\mathrm{layers}}} \mathrm{dilation}_i
\\]

\\[
\mathrm{receptivefield} = n_{\mathrm{blocks}} \cdot 2^{n_{\mathrm{layers}}}
\\]

With the second one for the specific case that we only always dilate with 2.

Now lets write the final WaveNet model and lets start with the `__init__`:

```py3
class WaveNet(nn.Module):
    def __init__(self, n_blocks: int = 3, n_layers: int = 10,
                 feat_width: int = 32, residual_width: int = 32,
                 skip_width: int = 32, kernel_size: int = 3,
                 bias: bool = True):
        super(WaveNet, self).__init__()
        self.n_blocks, self.n_layers = n_blocks, n_layers
        self.bias = bias

        self.filter_conv = self._conv_list(feat_width, residual_width,
                                           kernel_size)
        self.gate_conv = self._conv_list(feat_width, residual_width,
                                         kernel_size)
        self.skip_conv = self._conv_list(residual_width, skip_width, 1)
        self.feat_conv = self._conv_list(residual_width, feat_width, 1)

        self.dilations = [2**l for l in range(1, n_layers+1)]
```

With a helper function to generate all the list of convolutions:

```py3
    def _conv_list(self, in_channels: int, out_channels: int,
                             kernel_size: int) -> nn.ModuleList:
        module_list = []
        for _ in range(self.n_blocks * self.n_layers):
            module_list.append(nn.Conv1d(in_channels, out_channels, kernel_size,
                                         bias=self.bias))
        return nn.ModuleList(module_list)
```

And the forward pass:

```py3
    def forward(self, x: torch.Tensor) -> torch.Tensor:
        for i in product(self.n_blocks * self.n_layers):
            l = i % self.n_blocks
            dilated = dilate(feat, new=self.dilations[l], old=self.dilations[l-1])

            f = torch.sigmoid(self.filter_conv[i](dilated))
            g = torch.tanh(self.gate_conv[i](dilated))
            residual = f * g

            feat = dilated + self.feat_conv[i](residual)
            skip = skip + self.skip_conv[i](residual)
```

<!-- ### Faster WaveNet -->

<hr>

### References

<ol class="references">
    <li>
        <cite id="oordWaveNet2016">
            <span class="title">WaveNet: A Generative Model for Raw Audio</span>
            <br>
            <span>A. van den Oord et al., Sep. 2016</span>
            <br>
            <a href="https://arxiv.org/abs/1609.03499">arXiv:1609.03499</a>
        </cite>
    </li>
    <li>
        <cite id="oordPixelRNN2016">
            <span class="title">Pixel Recurrent Neural Networks</span>
            <br>
            <span>A. van den Oord, N. Kalchbrenner, and K. Kavukcuoglu, Aug. 2016</span>
            <br>
            <a href="https://arxiv.org/abs/1601.06759">arXiv:1601.06759</a>
        </cite>
    </li>
    <li>
        <cite id="oordPixelCNN2016">
            <span class="title">Conditional Image Generation with PixelCNN Decoders</span>
            <br>
            <span>A. van den Oord, N. Kalchbrenner, O. Vinyals, L. Espeholt, A. Graves, and K. Kavukcuoglu, Jun. 2016</span>
            <br>
            <a href="https://arxiv.org/abs/1606.05328">arXiv:1606.05328</a>
        </cite>
    </li>
    <li>
        <cite id="paineFast2016">
            <span class="title">Fast Wavenet Generation Algorithm</span>
            <br>
            <span>T. L. Paine et al., Nov. 2016</span>
            <br>
            <a href="http://arxiv.org/abs/1611.09482">arxiv:1611.09482</a>
        </cite>
    </li>
    <li>
        <cite id="hochreiterLong1997">
            <span class="title">Long Short-Term Memory</span>
            <br>
            <span>S. Hochreiter and J. Schmidhuber, Neural Computation, vol. 9, no. 8, Nov. 1997.</span>
            <br>
        </cite>
    </li>
    <li>
        <cite id="heDeep2015">
            <span class="title">Deep Residual Learning for Image Recognition</span>
            <br>
            <span>K. He, X. Zhang, S. Ren, and J. Sun, Dec. 2015</span>
            <br>
            <a href="http://arxiv.org/abs/1512.03385">arXiv:1512.03385</a>
        </cite>
    </li>
</ol>

<script type="text/javascript" src="wavenet.js"></script>
