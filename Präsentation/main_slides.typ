#import "@preview/polylux:0.3.1": *
#import themes.simple: *
#import "@preview/cetz:0.2.2"
#import "@preview/fletcher:0.5.1"

#import "@environments/boxdef:0.1.0": *
#import "@styles/LongSymbols:0.1.0": *

#set page(paper: "presentation-16-9")
#set text(size: 20pt, font: "New Computer Modern")

#let cL = $cal(L)$
#let drho = pad(right: -13pt)[$delta #move(dx: -12pt)[$rho$]$]
#let ci = $accent(i,°)$
#let vp = $bold(p)$
#let vq = $bold(q)$


#let pointset = ((0,0), (1,0.5), (3,1), (-3,4), (-2,-1), (-1,4), (0,1), (-1.5,2), (-2.5,1), (2,2))
#let realspectrum = ((0,0), (1,0), (3,0), (5,0), (7,0), (7.5,0), (8,0), (9,0), (10,0), (10.5,0), (10.7,0), (10.8,0), (12.0,0))
#let span_test_interval = ((0.5,-0.3), (10.25,0.3))


#show: simple-theme.with(
  footer: [(#utils.polylux-progress( ratio => [#calc.round(ratio * 100)#sym.percent])) of "_Studies of ERM Models with Correlated Disorder_", Tom Folgmann, 2024]
)

#title-slide[
  = Studies of ERM Models with Correlated Disorder
  #v(2em)
  === by Tom Folgmann
  #v(4em)
  #text(size: 15pt, [Bachelor Thesis Presentation, 2024])
]

#focus-slide[
  = What is ERM?
]

#slide[
  Imagine a system of $N in NN$ particles. 

  #pause
  #h(2em)$->$ How would you describe their relations?

  #pause
  #align(center)[
    #box(width: 50%, height: 50%, stroke: (paint: black, dash: "loosely-dotted"))[
      #align(center + horizon)[
        #cetz.canvas({
          import cetz.draw: *

          for p1 in pointset {
            for p2 in pointset {
              line(p1, p2, stroke: gray + 1pt)
            }
          }

          for point in pointset {
            circle(point, radius: 0.1, fill: black)
          }        
        })
      ]
    ]
  ]

  #pause 
  A system with $N in NN$ (related) particles can be described by a mathematical _Graph_.
]

#slide[
  Fundamentally, the properties of such graphs can be rendered in a _Laplacian Matrix_ $L$.
  #pause
  $ L(G) := D(G) - W(G). $
  #pause
  - $D(G)$ gives the _degree_ of each node: _Number of connected edges_.
  - $W(G)$ encodes the _strength_ (and direction) of the connections.
  #pause
  $
    D(G) &:= "diag"(d), &wide d_i &:= \#{e in E: v_i in e}, \
    W(G) &:= (w_(i j))_((i,j) in [N]^2), & w&: [N]^2 -> RR.
  $
  #pause
  .. special case is the _Adjacency Matrix_ $A$, where $w_(i,j) in {0,-1,1}$.
]

#slide[
  == Definition of the ERM Laplacian Matrix

  In the ERM model the Laplacian matrix is defined as
  $
    accent(U, ~)(f,r) := mat(
      Sigma(f,1), -f_(1 2), ..., -f_(1 N);
      -f_(2 1), Sigma(f,2), ..., -f_(2 N);
      dots.v, dots.v, dots.down, dots.v;
      -f_(N 1), -f_(N 2), ..., Sigma(f,N)
    ),
  $
  #pause 
  - _Interaction strength_ given by $f_(i j) eq.m f(r_i - r_j)$
  #pause
  - _Self-interaction_ given by $Sigma(f,i) eq.m sum_(j in [N] without {i}) f_(i j)$
]

#slide[
  == How to measure Eigenvalues?
  Let $Lambda:[p]->sigma_(P)(accent(U,~)(f,r))$ map bijectively into the _point spectrum_ of the ERM Laplacian.
  #pause

  #align(center + horizon)[
    #cetz.canvas({
      import cetz.draw: *

      content((0,0.08),$#long-symbol(sym.arrow.r, 20)$, anchor: "west")

      for point in realspectrum {
        circle(point, radius: 0.1, fill: black)
      }
    })
  ]
  #hide[
  ... results in an (unnormalized) density function 
  $
    E |-> sum_(i in [p]) delta_(Lambda_i)(E) wide in {0,p}
  $
  ]

]

#slide[
  == How to measure Eigenvalues?
  Let $Lambda:[p]->sigma_(P)(accent(U,~)(f,r))$ map bijectively into the _point spectrum_ of the ERM Laplacian.

  #align(center + horizon)[
    #cetz.canvas({
      import cetz.draw: *

      content((0,0.08),$#long-symbol(sym.arrow.r, 20)$, anchor: "west")

      for point in realspectrum {
        circle(point, radius: 0.1, fill: black)
      }

      rect(span_test_interval.at(0), span_test_interval.at(1), name: "testspace")
      content((name: "testspace", anchor: "north"), [#move(dy: -17pt, [testspace $E subset RR$])], anchor: "center")
    })
  ]
  #hide[
  ... results in an (unnormalized) density function 
  $
    E |-> sum_(i in [p]) delta_(Lambda_i)(E) wide in {0,p}
  $
  ]

]

#slide[
  == How to measure Eigenvalues?
  Let $Lambda:[p]->sigma_(P)(accent(U,~)(f,r))$ map bijectively into the _point spectrum_ of the ERM Laplacian.

  #align(center + horizon)[
    #cetz.canvas({
      import cetz.draw: *

      content((0,0.08),$#long-symbol(sym.arrow.r, 20)$, anchor: "west")

      for point in realspectrum {
        circle(point, radius: 0.1, fill: black)
      }

      rect(span_test_interval.at(0), span_test_interval.at(1), name: "testspace")
      content((name: "testspace", anchor: "north"), [#move(dy: -17pt, [testspace $E subset RR$])], anchor: "center")

      for matchtest in realspectrum {
        if matchtest.at(0) <= span_test_interval.at(1).at(0) {
          if matchtest.at(0) >= span_test_interval.at(0).at(0) {
            if matchtest.at(1) <= span_test_interval.at(1).at(1) {
              if matchtest.at(1) >= span_test_interval.at(0).at(1) {
                content(matchtest.zip((0,-0.5)).map(x => x.sum()),sym.arrow.t, anchor: "center")
              }
            }
          }
        }
      }
    })
  ]
  #pause
  ... results in an (unnormalized) density function 
  $
    E |-> sum_(i in [p]) delta_(Lambda_i)(E) wide in {0,p}
  $
]

#slide[
  == The Resolvent Eigenvalue Approximation
  .. by an example point $Lambda_i$ at $i in [p]$.
  #pause

  #set text(size: 20pt) 
  #align(center + horizon)[
    #cetz.canvas({
      import cetz.draw: *

      line((0,0), (5,0), stroke: black + 1pt)
      
      content((9,0.08),$#long-symbol(sym.arrow.r, 8)$, anchor: "west")
      content((15.5,0), $Re(z)$, anchor: "center")
      
      line((0,-2.5), (0,2.5), stroke: black + 1pt)
      content((0,2.5), sym.arrow.t, anchor: "center")
      content((0,3.2), $Im(z)$, anchor: "south")

      circle((7.03,0), radius: 2, stroke: (paint: gray, dash: "dotted"))
      
      line((7.03,0), (7.03,2), stroke: black + 1pt)
      content((7.03,2), sym.arrow.t, anchor: "north")
      
      bezier((7.1,1), (10,2), (9,1), stroke: black + 1pt)
      content((10,2), $Lambda_i + i dot epsilon$, anchor: "south", frame: "rect", padding: 10pt)
    })
  ]
  #set text(size: 25pt) // Standard size in "simple" theme, see code in "themes.simple"
  #pause
  #align(center)[$arrow.r.hook$ Usecase is the resolvent with a singularity at $Lambda_i$.]
]

#slide[
  .. the connection can be found in _Newtonian Physics_:
  #pause
  #align(center)[
    $[N] in.rev i -> (x_i:RR_(>0) -> RR^d)$ map of a particle's position
  ]
  #pause
  .. using our Laplacian ERM Matrix and Newtonian dynamics:
  #pause 
  $
    (d/(d t))^2 x_i (t) = -accent(U,~)(f,i |-> x_i (t))_(i,j) dot x_j (t), wide i,j in [N].
  $
  #pause
  .. looking at the behaviour with regard to the initial conditions:
  $
    (d/(d t))^2 angle.l x_i (t),x_i (0) angle.r = -accent(U,~)(f,i |-> x_i (t))_(i,j) dot angle.l x_j (t),x_i (0) angle.r.
  $
]

#slide[
  #align(center)[
    #cetz.canvas({
      import cetz.draw: *

      content((0,3), "In a visual approach " + $angle.l x_i (t), x_i (0) angle.r$ + " represents:", anchor: "south-east")

      line((0,0), (5,0), stroke: black + 1pt)
      content((5,0.08), sym.arrow.r, anchor: "center")
      content((5.5,0.1), $x_i (0)$, anchor: "west")

      line((0,0), (calc.cos(45deg) * 5,calc.sin(45deg) * 5), stroke: black + 1pt)
      content((calc.cos(45deg) * 5,calc.sin(45deg) * 5), sym.arrow.tr, anchor: "center")

      bezier((2,0), (calc.cos(45deg) * 2,calc.sin(45deg) * 2), (calc.cos(22.5deg) * 2.2,calc.sin(22.5deg) * 2.2), stroke: black + 1pt)

      // content((calc.cos(45deg) * 2,calc.sin(45deg) * 2), [#rotate(z: 45){content($x_i (t)$)}], anchor: "center")
      content((calc.cos(45deg) * 5.5, calc.sin(45deg) * 5.5), $x_i (t)$, anchor: "south-west")

    })
  ]
  #pause
  #columns(2)[
    Implementation of two initial configurations:
    #pause
    - $angle.l x_i (t), x_j (0) angle.r = delta_(i j)$ 
    #pause
    - $(d/(d t)) angle.l x_i (t), x_j (0) angle.r = 0$ 
    #pause
    .. leads to the _Resolvent representation_ (Green's function): of the ERM Laplacian: #footnote[With $x^*(t) = (i |-> x_i(t))$ and $F_(j,i)(t) := angle.l x_j (t),x_i (0) angle.r$.]
    #pause
    $
      (cL F_(j,i))(s) = plus.minus 1/(accent(U,~)(f,x^*(t))_(i,j) - delta_(i j) dot lambda_i^2).
    $
  ]
]

#slide[
  == Where does _Randomness_ come into play?
  #pause
  .. by a _slight_ modification of functions!
  #pause
  #align(center)[
    $Omega in.rev omega |-> R(omega)$, equivalent to $x$ from before.
  ]
  
  #hide[
    #set text(size: 20pt)
    #align(center)[
      #table(
        columns: (auto, auto),
        inset: 12pt,
        table.header([*Ev. step*], [*Meaning*]),
        $R$, "Random variable, abstract",
        $R(omega)$, "Vector of time dep. pos.",
        $R(omega)_i$, $i$ + "-th particle position, time dep. path",
        $R(omega)_i (t)$, "Position of " + $i$ + "-th particle at time " + $t$
    )]
    #set text(size: 25pt)
  ]
]

#slide[
  == Where does _Randomness_ come into play?
  .. by a _slight_ modification of functions!
  #align(center)[
    $Omega in.rev omega |-> R(omega)$, equivalent to $x$ from before.
  ]
  
  #set text(size: 20pt)
  #align(center)[
    #table(
      columns: (auto, auto),
      inset: 12pt,
      table.header([*Ev. step*], [*Meaning*]),
      $R$, "Random variable, abstract",
      $R(omega)$, "Vector of time dep. pos.",
      $R(omega)_i$, $i$ + "-th particle position, time dep. path",
      $R(omega)_i (t)$, "Position of " + $i$ + "-th particle at time " + $t$
  )]
  #set text(size: 25pt)
]

#slide[
  == The measurement of Eigenvalues

  Eigenvalue measurement can be done via the resolvent. Gaussian representation gives us:
  #pause
  $
    (accent(U, ~)(f,r) - z)_(i j)^(-1) = integral_(RR^d) phi_i dot phi_j med overbrace(
      (underbrace(
        e^(-(beta)/2 dot lr(angle.l (accent(U, ~)(f,r) - z) dot phi,phi angle.r)),
        "Boltzmann density"
      ) dot lambda),
      "Gaussian measure"
    )(d phi).
  $
  #pause
  This is already a good starting point to understand our _Correlated Disorder_ modification!
]

#slide[
  .. missing key elements:
  #pause
  - The _action_ (functional) $S_(z, R_omega)$ at a _test point_ $z in CC$ and a particle position vector $R_omega$.
  #pause
  #h(2em) $arrow.r.hook$ see the Boltzmann density exponent for implicit def.: #footnote[Expansion to a functional can be argued, see thesis p. 19. ]
  #pause
  $
    -beta/2 dot S_(z,R_omega)(phi):=-beta/2 dot lr(angle.l (accent(U, ~)(f,r) - z) dot phi,phi angle.r)
  $
  #pause
  - The _moment generating function_ $Z_(z, R_omega)[J]$. #pause It requires the _force field_ $J$.
]

#slide[
  #set heading(numbering: "1.")
  #counter(heading).update(2)
  #counter("defcount").update(21)
  #definitionsbox(
    "External Field Shift",
    [
      For $R:Omega -> V_(d,N)$ and $Phi in bb(F)_(d,N)$ we define 
      $
        J |-> -1/2 dot S_(z,R_omega)^((0))(Phi) + integral_(RR^d) J(x) dot Phi(-x) + J(-x) dot Phi(x) med lambda(d x)
      $
      the _field shifted action_ $text(S)_(z,R_omega)^((0))$ by an external field $J in cal(S)(RR^d)$.
    ]
  )
  #pause
  $
    arrow.r.hook #h(1em) delta/(delta J(x)) text(S)_(z,R_omega)^((0))[Phi] = ci dot Phi (-x). 
  $
]

#slide[
  == The Generative Operator
  Using these tools, an Operator generating $Z_(z,R_omega)$ can be deduced:
  #pause
  $
    Z_(z,R_omega)[J] = integral_(bb(F)_(d,N)) e^((S_(z,R_omega)^((0))Phi + S_(z,R_omega)^((italic("int")))Phi)[J]) d Phi = 
    underbrace(
      ["Ex"_(cal(L)_f)[
        integral_(bb(F)_(d,N)) e^(("S"_(z,R_omega)^((0))Phi)[dot])d Phi
      ]],
      "Generative Part"
    )
    [J].
  $
  $->$ Looking at different Taylor expansion terms yields different integrals.
]

#slide[
  == Feynman Diagrammatics - Edges
  .. conveniently using symmetry in Fourierspace:
  #pause
  $
    #fletcher.diagram($
      fletcher.edge("r", "-|>-")
    $) :=& (G_0(vp,z)) / rho_* \
    #fletcher.diagram($
      fletcher.edge(gamma, "wave")
    $) :=& (bb(E)((cal(F) drho_(R))(vq) dot (cal(F) drho_(R))(-vq))) / rho_*
  $
  #pause
  .. possible connections of these edges are given by _vertices_:
]

#slide[
  == Feynman Diagrammatics - Vertices
  #pause
  $
    #grid(
      columns: 4,
      column-gutter: 20pt,
      row-gutter: 10pt,
      align: (right + horizon, left + horizon, center + horizon, center + horizon),
      fletcher.diagram({
        let S = (0,0)
        let (A,B,C) = ((1.5,0),(calc.cos(140deg),calc.sin(140deg)),(calc.cos(220deg),calc.sin(220deg)))

        fletcher.edge(S,A,$vp+vq$,"-|>-")
        fletcher.edge(S,B,$vp$,left,"-<|-")
        fletcher.edge(S,C,$vq$,"wave")
      }),$:= mu_z (vp,vq)$, $=>$, "Three-point Vertex",
      fletcher.diagram({
        let S = (0,0)
        let (A,B,C,D) = ((1.5,0),(calc.cos(140deg),calc.sin(140deg)),(calc.cos(220deg),calc.sin(220deg)),(calc.cos(180deg),calc.sin(180deg)))

        fletcher.edge(S,A,$vp+vq$,"-|>-")
        fletcher.edge(S,B,$vp$,left,"-<|-")
        fletcher.edge(S,C,$vq_2$,"wave")
        fletcher.edge(S,D,$vq_1$,center,label-pos: 1,"wave")
      }), $:=-V_z (vp,-vq_1)$, $=>$, "Four-point Vertex"
    )
  $
  #pause
  .. which completes the set of Feynman rules.
]

#slide[
  == How can we use diagrammatics?

  .. displaying summands in operator expansion. 

  #pause
  #align(center)[Observe *one* loop diagrams:]
  $
    #grid(
      columns: 4,
      column-gutter: 20pt,
      align: center + top,
      fletcher.diagram({
        let (B,C,H,E) = ((-1,0),(0,0),(0,-0.5),(1,0))

        fletcher.edge(B,C,$vp$,"-|>-")
        fletcher.edge(C,H,"wave", bend: 80deg)
        fletcher.edge(H,C,"wave", bend: 80deg)
        fletcher.edge(C,E,$vp$,"-|>-")
      }),
      fletcher.diagram({
        let (B,C1,C2,E) = ((-1,0),(-0.5,0),(0.5,0),(1,0))

       fletcher.edge(B,C1,$vp$,"-|>-")
       fletcher.edge(C1,C2,"wave", bend: 90deg)
       fletcher.edge(C1,C2,$vq$,right,"-|>-")
       fletcher.edge(C2,E,$vp$,"-|>-")
      }),
      fletcher.diagram({
        let (B,C1,C2,E) = ((-1,0),(-0.5,0),(0.5,0),(1,0))

       fletcher.edge(C1,C2,"wave", bend: 90deg)
       fletcher.edge(C1,C2,$vq$,right,"-|>-")
       fletcher.edge(C2,E,$vp$,"-|>-")
      }),
      fletcher.diagram({
        let (B,C1,C2,E) = ((-1,0),(-0.5,0),(0.5,0),(1,0))

       fletcher.edge(C1,C2,"wave", bend: 90deg)
       fletcher.edge(C1,C2,$vq$,right,"-|>-")
      })
    )
  $
  #pause
  .. represented diagrams are _irreducible_: $Z_(z,R_omega)[J] = exp(sum_(C in cal(C)) C)$.
]

#slide[
  == Integral representations #footnote[Attention! The terms have been simplified. For more details see Thesis sec. 2.4.2.]
  #pause
  #align(center)[
    #grid(
      columns: 2,
      column-gutter: 10pt,
      row-gutter: 10pt,
      align: (right + top, left + top),
      fletcher.diagram({
        let (B,C1,C2,E) = ((-1,0),(-0.5,0),(0.5,0),(1,0))

       fletcher.edge(B,C1,$vp$,"-|>-")
       fletcher.edge(C1,C2,"wave", bend: 90deg)
       fletcher.edge(C1,C2,$vq$,right,label-sep: 1pt,"-|>-")
       fletcher.edge(C2,E,$vp$,"-|>-")
      }),
      $
        = (G_0 (vp,z)^2) / rho_* dot integral_(RR^d) G_0(vq-vp,z) dot mu_z (vp,-vq)^2 med d vq,
      $,
      fletcher.diagram({
        let (B,C1,C2,E) = ((-1,0),(-0.5,0),(0.5,0),(1,0))

       fletcher.edge(B,C1,$vp$,"-|>-")
       fletcher.edge(C1,C2,"wave", bend: 90deg)
       fletcher.edge(C1,C2,$vq$,right,label-sep: 1pt,"-|>-")
       fletcher.edge(C2,E,$vp$,"-|>-")
      }),
      $
        = -(2 dot G_0(vp,z)) / rho_* dot integral_(RR^d) G_0(vp - vq,z) dot mu_z(vp,-vq) med d vq,
      $,
      fletcher.diagram({
        let (B,C1,C2,E) = ((-1,0),(-0.5,0),(0.5,0),(1,0))

       fletcher.edge(C1,C2,"wave", bend: 90deg)
       fletcher.edge(C1,C2,$vq$,right,label-sep: 1pt,"-|>-")
      }),
      $
        = 1/rho_* dot integral_(RR^d) G_0(vp - vq,z) med d vq.
      $
    ) 
  ]
]



#focus-slide[
  = What is Correlated Disorder?
]

#slide[
  == Second Moment of density fluctuations
  #pause
  .. previously we used an _a priori_ probability density $R -> 1/abs(V_(d,N))$

  #pause
  $arrow.r.hook$ This did not account for the _structure_ of our system. 

  #pause 
  Main question to solve:

  #pause
  #align(center)[
    *How can we include _structure_ in our probability density?*
  ]
]

#slide[
  == The (radial) Particle Distribution Density
  #pause
  #grid(
    columns: 2,
    column-gutter: 20pt,
    align: (center + top, center + horizon),
    "To calculate possibility of finding particles near a given reference " + $r_0$ + " we used the " + text(style: "italic", "radial distribution function") + $
      g_(r_0)(r) = integral_(RR^d) rho_N^((2))(r_0 + r,r) med d r,
    $ + "while " + $rho_N^((2))$ + " reflects integration of " + $exp(-beta dot H(r,dot))$ + " for remaining particles.",
    cetz.canvas({
      import cetz.draw: *

      circle((0,0), radius: 5, stroke: (paint: black, dash: "loosely-dotted"), fill: gray)
      circle((0,0), radius: 3, stroke: (paint: black, dash: "loosely-dotted"), fill: white)

      circle((0,0), radius: 4, stroke: black + 1pt)

      line((3,0),(5,0), stroke: black + 1pt)
      content((5.08,0.08), sym.arrow.r, anchor: "east")
      content((2.92,0.08), sym.arrow.l, anchor: "west")

      circle((0,0), radius: 0.05, fill: black)
      content((0,0), $r_0$, anchor: "north")
    })
  )
]

#slide[
  == How can we use this now?
  #pause
  #align(center)[
    #box(stroke: black + 1pt, inset: 15pt)[
      #align(center)[
        There is a particular connection between $g$ and \
        the _static structure factor_ $S_*$!
      ]
    ]
  ]
  #pause
  .. namely given by 
  $
    S_*(vq) = 1 + integral_(RR^d) (g_0(bold(r)) - 1) dot e^(ci dot vq dot bold(r)) med d bold(r).
  $
]

#slide[
  == What does $g_0$ look like? #footnote[Looking at a soft sphere model, see later.]
  #pause
  #align(center)[
    #image(height:9.7em, "img/example_radial_dist_fnc_soft_spheres.png")
  ]
]

#slide[
  == Resulting in the Static Structure Factor
  #pause
  #align(center)[
    #image("img/example_static_structure_factor_soft_spheres.png")
  ]
]



#focus-slide[
  = Where did we implement this, what did it change?
]

#slide[
  == Analytical Aspects
  #pause
  We have established a new expectancy for $drho_R (vq) dot drho_R (-vq)$:
  #pause
  #align(center)[
    $
      angle.l drho_R (vq), drho_R (-vq) angle.r = 1/rho_* dot S_*(vq). 
    $
  ]
  #pause
  This results in a slight change in Feynman edges:
  #pause
  #align(center)[
    $
      #fletcher.diagram($
        fletcher.edge(gamma, "wave")
      $) := (S_*(vq)) / rho_*
    $
  ]
]

#slide[
  == Analytical Aspects
  #pause
  From this the Integrands of the irreducible diagrams gain a factor:
  #pause
  #align(center)[
    $
      #grid(
        columns: 2,
        column-gutter: 20pt,
        align: (center + top, center + top),
        fletcher.diagram({
          let (B,C1,C2,E) = ((-1,0),(-0.5,0),(0.5,0),(1,0))

          fletcher.edge(B,C1,$vp$,"-|>-")
          fletcher.edge(C1,C2,"wave", bend: 90deg)
          fletcher.edge(C1,C2,$vq$,right,label-sep: 1pt,"-|>-")
          fletcher.edge(C2,E,$vp$,"-|>-")
        }),
        $
          = (G_0 (vp,z)^2) / rho_* dot integral_(RR^d) G_0(vq-vp,z) dot mu_z (vp,-vq)^2 dot S_*(vq) med d vq,
        $
      )
    $ 
  ]
  #pause
  This also affects the Self-Energy:
  #pause
  $
    Sigma_(S_*)^((1))(vp,z) = 1/rho_* dot integral_(RR^d) S_*(vq) dot G_0(vp - vq,z) dot S_*(vq) med d vq.
  $
]

#focus-slide[
  Can we in any way compare our results?
]

#slide[
  == The Approach of Martin-Mayor
  #pause
  Here, a _superposition approximation_ was used:
  #align(center)[
    $
      1/abs(V_(d,N)) dot exp(-beta dot U(r)) approx 1/abs(V_(d,N)) dot exp(-beta dot sum_(i in [N-1]) u(r_i - r_(i + 1)))
    $ 
  ]
  #pause
  This approach only considers _direct neighbors_ in a chain. #pause Compare:
  $
    exp(-beta dot U(r)) = exp(-beta dot sum_((i,j) in [N]^2) u(r_i - r_j)).
  $
]

#slide[
  == The Approach of Martin-Mayor
  #pause
  An implementation of $r|->exp(-beta dot sum ..)/abs(V_(d,N))$ is done:
  $
    cal(f)(r) :approx (f(r))/abs(V_(d,N)) dot exp(-beta dot sum_((i,j) in [N]^2) u(r_i - r_j)).
  $
  #pause
  This has an explicit approximation built into the spring function!
]

#slide[
  == The Approach of Martin-Mayor
  #pause
  In a consequence, the bare propagator changes:
  #pause
  $
    G_0(vp,z) = 1/(z - rho_* dot (cal(f)(bold(0)) - S_*(vp))) eq.not underbrace(1/(z - rho_* dot (f(bold(0)) - S_*(vp))),"Our Approach").
  $
  #pause
  - We explicitly did not approximate the spring function.
  #pause
  - We did not change the zeroth order term in the propagator.
]

#focus-slide[
  = What did a numerical model show?
]

#slide[
  == Analytical Foundation
  #pause
  We chose a _step function_ for the spring mapping:
  $
    RR in.rev r |-> f_a^((italic("num")))(r) = cases(
      1 "if" r < a ",",
      0 "else".
    )
  $
  #pause
  .. resulting in a pair potential 
  #pause
  $
    V_(d,N) in.rev R |-> U_a^((italic("num")))(R) = sum_((i,j) in [N]^2) cases(
      1/2 dot (norm(R_i - R_j) - a)^2 "if" norm(R_i - R_j) < a",",
      0 "else".
    )
  $
]

#slide[
  == Results using the Hypernetted Chain
  #pause
  #align(center)[
    #image(height: 9.7em,"img/results_sound_velocity.png")
  ]
  #pause
  #text(size: 20pt)[
    $->$ Sadly no major differences in the velocity of sound noticeable.
  ]
]