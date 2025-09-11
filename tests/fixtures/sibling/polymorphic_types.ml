type extended_color = [ `Red | `Green | `Blue | `Hex of int ]


type cpu_type =
  [ `X86
  | `X86_64
  | `ARM
  | `ARM64
  | `ARM64_32
  | `POWERPC
  | `POWERPC64
]