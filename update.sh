#!/usr/bin/env bash
set -Eeuo pipefail
shopt -s nullglob

cd "$(dirname "$(greadlink -f "$BASH_SOURCE")")"

declare branches=(
    "stable"
    "mainline"
)

# Current nginx versions
# Remember to update pkgosschecksum when changing this.
declare -A nginx=(
    [mainline]='1.27.4'
    [stable]='1.26.3'
)

# Current njs versions
declare -A njs=(
    [mainline]='0.8.9'
    [stable]='0.8.9'
)

# Current njs patchlevel version
# Remember to update pkgosschecksum when changing this.
declare -A njspkg=(
    [mainline]='1'
    [stable]='1'
)

# Current nginx package patchlevel version
# Remember to update pkgosschecksum when changing this.
declare -A pkg=(
    [mainline]=1
    [stable]=1
)

# Current built-in dynamic modules package patchlevel version
# Remember to update pkgosschecksum when changing this
declare -A dynpkg=(
    [mainline]=1
    [stable]=2
)

declare -A debian=(
    [mainline]='bookworm'
    [stable]='bookworm'
)

declare -A alpine=(
    [mainline]='3.21'
    [stable]='3.20'
)

# When we bump njs version in a stable release we don't move the tag in the
# pkg-oss repo.  This setting allows us to specify a revision to check out
# when building packages on architectures not supported by nginx.org
# Remember to update pkgosschecksum when changing this.
declare -A rev=(
    [mainline]='${NGINX_VERSION}-${PKG_RELEASE}'
    [stable]='${NGINX_VERSION}-${PKG_RELEASE}'
)

# Holds SHA512 checksum for the pkg-oss tarball produced by source code
# revision/tag in the previous block
# Used in builds for architectures not packaged by nginx.org
declare -A pkgosschecksum=(
    [mainline]='973690e64fa47e3704e817a3b08205b9e3f8c0cbe31825d9d62a81c11eb3aa186df015f27fdfd48c8799ffc528e38a9168c592ae665e4835c2d28638ec5f7845'
    [stable]='3a4e869eded0c71e92f522e94edffea7fbfb5e78886ea7e484342fa2e028c62099a67d08860c249bf93776da97b924225e0d849dbb4697b298afe5421d7d6fea'
)

get_packages() {
    local distro="$1"
    shift
    local branch="$1"
    shift
    local perl=
    local r=
    local sep=

    case "$distro:$branch" in
    alpine*:*)
        r="r"
        sep="."
        ;;
    debian*:*)
        sep="+"
        ;;
    esac

    case "$distro" in
    *-perl)
        perl="nginx-module-perl"
        ;;
    esac

    echo -n ' \\\n'
    case "$distro" in
    *-slim)
        for p in nginx; do
            echo -n '        '"$p"'=${NGINX_VERSION}-'"$r"'${PKG_RELEASE} \\'
        done
        ;;
    *)
        for p in nginx; do
            echo -n '        '"$p"'=${NGINX_VERSION}-'"$r"'${PKG_RELEASE} \\\n'
        done
        for p in nginx-module-xslt nginx-module-geoip nginx-module-image-filter $perl; do
            echo -n '        '"$p"'=${NGINX_VERSION}-'"$r"'${DYNPKG_RELEASE} \\\n'
        done
        for p in nginx-module-njs; do
            echo -n '        '"$p"'=${NGINX_VERSION}'"$sep"'${NJS_VERSION}-'"$r"'${NJS_RELEASE} \\'
        done
        ;;
    esac
}

get_packagerepo() {
    local distro="${1%-perl}"
    distro="${distro%-slim}"
    shift
    local branch="$1"
    shift

    [ "$branch" = "mainline" ] && branch="$branch/" || branch=""

    echo "https://nginx.org/packages/${branch}${distro}/"
}

get_packagever() {
    local distro="${1%-perl}"
    shift
    local branch="$1"
    shift
    local package="$1"
    shift
    local suffix=

    [ "${distro}" = "debian" ] && suffix="~${debianver}"

    case "${package}" in
        "njs")
            echo ${njspkg[$branch]}${suffix}
            ;;
        "dyn")
            echo ${dynpkg[$branch]}${suffix}
            ;;
        *)
            echo ${pkg[$branch]}${suffix}
            ;;
    esac
}

get_buildtarget() {
    local distro="$1"
    case "$distro" in
        alpine-slim)
            echo base
            ;;
        alpine)
            echo module-geoip module-image-filter module-njs module-xslt
            ;;
        debian)
            echo base module-geoip module-image-filter module-njs module-xslt
            ;;
        *-perl)
            echo module-perl
            ;;
    esac
}

generated_warning() {
    cat <<__EOF__
#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "update.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#
__EOF__
}

for branch in "${branches[@]}"; do
    for variant in \
        alpine{,-perl,-slim} \
        debian{,-perl}; do
        echo "$branch: $variant dockerfiles"
        dir="$branch/$variant"
        variant="$(basename "$variant")"

        [ -d "$dir" ] || continue

        template="Dockerfile-${variant%}.template"
        {
            generated_warning
            cat "$template"
        } >"$dir/Dockerfile"

        debianver="${debian[$branch]}"
        alpinever="${alpine[$branch]}"
        nginxver="${nginx[$branch]}"
        njsver="${njs[${branch}]}"
        revver="${rev[${branch}]}"
        pkgosschecksumver="${pkgosschecksum[${branch}]}"

        packagerepo=$(get_packagerepo "$variant" "$branch")
        packages=$(get_packages "$variant" "$branch")
        packagever=$(get_packagever "$variant" "$branch" "any")
        njspkgver=$(get_packagever "$variant" "$branch" "njs")
        dynpkgver=$(get_packagever "$variant" "$branch" "dyn")
        buildtarget=$(get_buildtarget "$variant")

        gsed -i \
            -e 's,%%ALPINE_VERSION%%,'"$alpinever"',' \
            -e 's,%%DEBIAN_VERSION%%,'"$debianver"',' \
            -e 's,%%DYNPKG_RELEASE%%,'"$dynpkgver"',' \
            -e 's,%%NGINX_VERSION%%,'"$nginxver"',' \
            -e 's,%%NJS_VERSION%%,'"$njsver"',' \
            -e 's,%%NJS_RELEASE%%,'"$njspkgver"',' \
            -e 's,%%PKG_RELEASE%%,'"$packagever"',' \
            -e 's,%%PACKAGES%%,'"$packages"',' \
            -e 's,%%PACKAGEREPO%%,'"$packagerepo"',' \
            -e 's,%%REVISION%%,'"$revver"',' \
            -e 's,%%PKGOSSCHECKSUM%%,'"$pkgosschecksumver"',' \
            -e 's,%%BUILDTARGET%%,'"$buildtarget"',' \
            "$dir/Dockerfile"

        done

    for variant in \
        alpine-slim \
        debian; do \
        echo "$branch: $variant entrypoint scripts"
        dir="$branch/$variant"
        cp -a entrypoint/*.sh "$dir/"
        cp -a entrypoint/*.envsh "$dir/"
    done
done
