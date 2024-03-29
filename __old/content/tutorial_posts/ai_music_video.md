+++
title = "Making music videos with AI"
slug = "ai_music_video"
tldr =  "Iteratively sampling from a generative image model to generate videos conditioned on the lyrics of songs."
+++

Let's start right away with some results from the setup.

### Eating Hooks

<a href="https://www.youtube.com/watch?v=u6ECMXk3JAw">Eating Hooks - Moderat</a>

<details>
<summary>Input Screen-play</summary>
<pre>

| time | prompt                                                                                    |
| ---- | ----------------------------------------------------------------------------------------- |
| 0:0  | psychedlic pattern jungle plants and people dancing                                       |
| 1:15 | a crowd of dacing people in a techno club, electric colors                                |
| 1:30 | a oil painting of a person in a portal with a forrest inside                              |
| 1:45 | painting of Zdzisław Beksiński of a person without a face under the shade of a palm tree  |
| 2:00 | monopoly the board game, the box of the monopoly board game                               |
| 2:10 | a art nouveau illustration of a sunflower                                                 |
| 2:20 | a painting of a colorful mosque, orientalism                                              |
| 2:25 | an orientalistic painting of desert                                                       |
| 2:30 | a arabic prince on a camel                                                                |
| 2:35 | a yak standing by a stupa, watercolor                                                     |
| 2:40 | low poly ink drawing of buddha meditating, psychedlic                                     |
| 2:45 | a stone statue of buddha                                                                  |
| 2:47 | a colorful stone statue of buddha                                                         |
| 2:50 | a close up biological illustration of a mouth                                             |
| 2:55 | a wide opened mouth biting into a piece of metal                                          |
| 3:00 | a painting of a buddhist shrine stupa beautiful realistic                                 |
| 3:20 | psychedlic painting of jungle plants and people dancing, acid, hippies                    |
| 3:00 | a colorful stained window of a church, colorful light, romantic painting                  |
| 3:50 | The girl is eating the hooks that tear her, She is walking back                           |
| 4:00 | the portal to hell, a renaissance painting of the entrance to the hell, flames            |
| 4:20 | an empty room with a butcher hook at the ceiling"                                         |
| 4:30 | meditation and medication, psychedlic                                                     |
| 5:00 | psychedlic painting of jungle plants and people dancing, acid, hippies, meditation        |
| 5:10 | psychedlic painting of palm tree                                                          |
| 5:15 | psychedlic painting of hippie woman dancing                                               |
| 5:20 | a pattern of flowers, 60s music posters                                                   |
| 5:25 | a van gogh painting of a hill with trees and flowers                                      |
| 5:30 | under the skin of the person, lies the world, we see the world under the skin, psychedlic |
| 5:35 | the world as a globe, watercolor                                                          |
| 5:40 | an explosion of color                                                                     |
| 5:45 | people dancing in a techno club with strobing lights                                      |
| 5:50 | michelangelo painting in a church                                                         |
| 5:55 | painting of jesus at the cross                                                            |
| 6:00 | christian gothic painting of the sinner god and jesus                                     |
| 6:30 | psychedlic painting of jungle plants and people dancing, acid, hippies, meditation        |

</pre>
</details>

{{< video "Eating Hooks" >}}


### Lucy in the Sky with Diamonds

As all the videos are pretty intense and inconsistent, I think psychdelic rock lends itself quite naturally to this kind of video… What better than the
classic [Lucy in the sky](https://en.wikipedia.org/wiki/Lucy_in_the_Sky_with_Diamonds) from The Beatle's Sgt. Pepper album.

Input here are only the lyrics plus "The Beatles" at the beginning and "The end" at the end. 

<details>
<summary>Input Screen-play</summary>
<pre>

| Text line                                       | cue   |
| ----------------------------------------------- | ----- |
| The Beatles                                     | 0     |
| Picture yourself in a boat on a river           | 6     |
| With tangerine trees and marmalade skies        | 11.6  |
| Somebody calls you, you answer quite slowly     | 18.7  |
| A girl with kaleidoscope eyes                   | 24    |
| Cellophane flowers of yellow and green          | 32.2  |
| Towering over your head                         | 37.5  |
| Look for the girl with the sun in her eyes      | 42.6  |
| And she's gone                                  | 46.7  |
| Lucy in the sky with diamonds                   | 50    |
| Lucy in the sky with diamonds                   | 55    |
| Lucy in the sky with diamonds, ahh              | 60    |
| ahhhhhh                                         | 66    |
| Follow her down to a bridge by a fountain       | 68.4  |
| Where rocking horse people eat marshmallow pies | 73.6  |
| Everyone smiles as you drift past the flowers   | 80.4  |
| That grow so incredibly high                    | 85.5  |
| Newspaper taxis appear on the shore             | 93.4  |
| Waiting to take you away                        | 98    |
| Climb in the back with your head in the clouds  | 103.3 |
| And you're gone                                 | 107   |
| Lucy in the sky with diamonds                   | 110   |
| Lucy in the sky with diamonds                   | 115   |
| Lucy in the sky with diamonds, ahh              | 120   |
| ahhhhhh                                         | 125   |
| Picture yourself on a train in a station        | 129   |
| With plasticine porters with looking glass ties | 134.2 |
| Suddenly someone is there at the turnstile      | 141   |
| The girl with kaleidoscope eyes                 | 146   |
| Lucy in the sky with diamonds                   | 154   |
| Lucy in the sky with diamonds                   | 159   |
| Lucy in the sky with diamonds, ahh              | 164   |
| ahhhhh                                          | 168.3 |
| Lucy in the sky with diamonds                   | 173.5 |
| Lucy in the sky with diamonds                   | 178.5 |
| Lucy in the sky with diamonds, ahh              | 183.5 |
| ahhhhhhhh                                       | 188.3 |
| The End                                         | 209   |

</pre>
</details>

#### Version 0.2

{{< video "lucy_000" >}}

<details>
<summary>Sampling strategy</summary>
<pre>
- Sampled keyframes from VQGAN at 15FPS
- 100 sampling iterations per keyframe
- Interpolation between keyframe latents in latent space at 60FPS
</pre>
</details>


### White Rabbit

<details>
<summary>Input Screen-play</summary>
<pre>

| Text line                                                               | cue |
| ----------------------------------------------------------------------- | --- |
| The rock band jefferson airplane is playing                             | 0   |
| Grace Slick singing intp a microphone                                   | 7   |
| One pill makes you larger                                               | 15  |
| And one pill makes you small                                            | 34  |
| Mother is giving Alice a pill                                           | 55  |
| There is Alice in Wonderland. She is ten feet tall                      | 43  |
| Alice in Wonderland is chasing a rabbit                                 | 56  |
| The girl is falling through a hole                                      | 60  |
| a hookah smoking caterpillar, a caterpillar smoking a shisha            | 65  |
| the caterpillar is calling with the phone                               | 70  |
| Alice in wonderland is becoming small                                   | 75  |
| Men are standing on a chessboard. A knight is standing on a chessboard. | 85  |
| The knight is lifting his arm. The knight is giving directions.         | 88  |
| The girl is eating a mushroom. There is a weird kind of mushroom.       | 93  |
| The girl is thinking really slow.                                       | 96  |
| Alice in Wonderland                                                     | 101 |
| When logic and proportion have fallen sloppy dead                       | 110 |
| The white knight is talking backward                                    | 120 |
| The red queen. The red queen is off with her head.                      | 123 |
| There is a dormouse. A kind of mouse.                                   | 129 |
| Feed your head, feed your head, feed your head                          | 135 |
| Alice in Wonderland                                                     | 150 |

</pre>
</details>

#### Version 0.3

{{< video "white_rabbit_000" >}}

<details>
<summary>Sampling strategy</summary>
<pre>
- Sampled only one key-frame for each text, each 5.000 iterations each
- Interpolation at 60 FPS in latent space
- Added low-freq noise bias in latent space
</pre>
</details>

### Dark Star

[Dark Star](https://en.wikipedia.org/wiki/Dark_Star_(song)) by the [Grateful Dead](https://en.wikipedia.org/wiki/Grateful_Dead) with the the famously elusive lyrics of [Robert Hunter](https://en.wikipedia.org/wiki/Robert_Hunter_(lyricist)). This is the
short studio version… Making a video for a great 40min live performance of the song would be too expensive ;)

Input here are only the lyrics plus "The Grateful Dead" at the beginning and "The end" at the end. (Notice how the first frames really do look like a Grateful dead cover! The VQGAN really knows everything.)

<details>
<summary>Input Screen-play</summary>
<pre>

| Text line                                            | cue   |
| ---------------------------------------------------- | ----- |
| The Grateful dead                                    | 0.0   |
| Dark star crashes                                    | 14.8  |
| Pouring its light Into ashes                         | 19.7  |
| Reason tatters                                       | 25    |
| The forces tear loose From the axis                  | 30    |
| Searchlight casting                                  | 35.3  |
| For faults in the Clouds of delusion                 | 40.1  |
| Shall we go                                          | 45.5  |
| You and I While we can?                              | 48.7  |
| Through The transitive nightfall Of diamonds         | 56    |
| Mirror shatters                                      | 80.1  |
| In formless reflections Of matter                    | 84.8  |
| Glass hand dissolving To ice petal flowers Revolving | 90    |
| Lady in velvet Recedes In the nights of goodbye      | 100.6 |
| Shall we go                                          | 110.6 |
| You and I While we can?                              | 113.4 |
| Through The transitive nightfall Of diamonds         | 120   |
| The End                                              | 150   |

</pre>
</details>

#### Version 0.2
<details>
    <summary>Sampling strategy</summary>
<pre>
- Sampled keyframes from VQGAN at 15FPS
- 100 sampling iterations per keyframe
- Interpolation between keyframe latents in latent space at 60FPS
</pre>
</details>

{{< video "dark_star_001" >}}

#### Version 0.1
<details>
    <summary>Sampling strategy</summary>
<pre>
- Sampled keyframes from VQGAN at 15FPS
- 100 sampling iterations per keyframe
- Interpolation to 30FPS with ffmpeg 
</pre>
</details>

{{< video "dark_star_000_with_audio" >}}

### Implementation

wip

### References
<ol class="references">
    <li>
        <cite id="esser2020taming">
            <span class="title">Taming Transformers for High-Resolution Image Synthesis</span>
            <br>
            <span>Patrick Esser and Robin Rombach and Björn Ommer</span>
            <br>
            <a href="https://arxiv.org/abs/2012.09841">arXiv:2012.09841</a>
        </cite>
    </li>
    <li>
        <cite id="radford2021learning">
            <span class="title">Learning transferable visual models from natural language supervision</span>
            <br>
            <span>Radford, Alec and Kim, Jong Wook and Hallacy, Chris and Ramesh, Aditya and Goh, Gabriel and Agarwal, Sandhini and Sastry, Girish and Askell, Amanda and Mishkin, Pamela and Clark, Jack and others</span>
            <br>
            <a href="https://arxiv.org/abs/2103.00020">arXiv:2103.00020</a>
        </cite>
    </li>
    <li>
        <cite id="advadnoun">
            <span class="title">LatentVisions</span>
            <br>
            <span>@advadnoun</span>
            <br>
            <a href="https://www.patreon.com/patronizeme/">patronizeme</a>
        </cite>
    </li>
    <li>
        <cite id="beatles1967lucy">
            <span class="title">Lucy in the Sky with Diamonds</span>
            <br>
            <span><i>Performed by:</i> The Beatles, <i>Lyrics by:</i> John Lennon and Paul McCartney</span>
        </cite>
    </li>
    <li>
        <cite id="dead1968dark">
            <span class="title">Dark Star</span>
            <br>
            <span><i>Performed by:</i> The Gratful Dead, <i>Lyrics by:</i> Robert Hunter</span>
        </cite>
    </li>
</ol>

