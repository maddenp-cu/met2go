# metkit

A conda recipe for [MET](https://met.readthedocs.io/en/latest/) and [METPlus](https://metplus.readthedocs.io/en/latest/)

To build and upload a package to anaconda.org:

- Clone this repo on an `aarch64` or `x86_64` Linux system. The built package will match the system architecture.
- Run `./build`.
- If prompted, enter your anaconda.org credentials for package upload.
- When finished, you may remove the `conda` directory to reclaim disk space.
- Repeat, if necessary, for another architecture.
