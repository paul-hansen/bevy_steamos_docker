A Docker image for building [Bevy](https://bevy.org) games for SteamOS (SteamDeck).

Building apps for Linux from your development PC and sharing that build with another PC can be inconsistent because Linux uses shared libraries and your PC may have linked newer libraries that are incompatible with the target PC's older libraries. This is especially true with the SteamDeck as it may not have the newest versions (e.g. glibc) and cannot be easily updated until Steam releases their official update.

The solution is to build in an environment with older versions of these libraries that are forwards compatible with the new versions to ensure maximum compatibility. Valve provides containers made for doing this.

This Docker image simply uses Valve's Docker image and adds Rust and the libraries needed for compiling Bevy apps on Linux.

## Basic Usage

Build the docker image
```
docker build -t bevy_steamos https://raw.githubusercontent.com/paul-hansen/bevy_steamos_docker/main/Dockerfile
```

From your project directory, run:

```
docker run -v .:/usr/src/project bevy_steamos
```

By default the container will run `cargo build --release` on your project directory. You can find the resulting binary file in the `./target/release` directory

## Advanced Usage

### Custom Build Commands

You can override the default build command.
For example, to build a debug build (without `--release`):
```
docker run -v .:/usr/src/project bevy_steamos cargo build
```

### Custom Rust Version

By default, the image uses the latest stable Rust version. To specify a different Rust version:
```
docker build --build-arg RUST_VERSION=1.79.0 -t bevy_steamos https://raw.githubusercontent.com/paul-hansen/bevy_steamos_docker/main/Dockerfile
```

You can use specific versions (e.g., `1.79.0`), or channel names (`stable`, `beta`, `nightly`).

### Pinned Dockerfile Version

To build using a specific version of the Dockerfile, you can use the commit hash in the URL instead of `main` when building:
```
docker build -t bevy_steamos https://raw.githubusercontent.com/paul-hansen/bevy_steamos_docker/2f782851ea88509b0406473d600701f007bd8088/Dockerfile
```

When using in places like CI, this ensures your build process remains consistent even if this repository is updated.

## Alternatives

- [zigbuild](https://github.com/rust-cross/cargo-zigbuild): Seems like a cool solution but I haven't tried it yet. Credit to birus on discord for sharing:
  > https://github.com/rust-cross/cargo-zigbuild allows you to choose your glibc version. I run `cargo zigbuild --release --target x86_64-unknown-linux-gnu.2.27` and it works with steam deck.
  Source: https://discord.com/channels/691052431525675048/1267707895164702751/1267864473549537413
