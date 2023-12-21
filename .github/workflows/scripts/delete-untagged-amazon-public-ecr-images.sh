#!/bin/bash
# vim:sw=2:ts=2:sts=2:et
# Inspired by https://github.com/zeek/zeek/blob/master/ci/public-ecr-cleanup.sh

set -eu

REPOSITORY_NAME=nginx-unprivileged
BATCH_DELETE_SIZE=100 # The max delete size allowed by the 'batch-delete-image' aws CLI command is 100

function batch_delete {
  while read -r batch; do
    if [ -z "${batch}" ]; then
      break
    fi

  echo "Deleting ${batch}"
  aws ecr-public batch-delete-image --repository-name "${REPOSITORY_NAME}" --image-ids ${batch}

  done < <(xargs -L ${BATCH_DELETE_SIZE} <<<"$1")
}

# Find untagged manifest lists and delete them first as
# otherwise any referenced untagged images can not be deleted.
IMAGE_DIGESTS=$(aws ecr-public describe-images \
  --repository-name "${REPOSITORY_NAME}" \
  --query 'imageDetails[?!imageTags && (contains(imageManifestMediaType, `manifest.list.v2`) || contains(imageManifestMediaType, `image.index.v1`))].{imageDigest: join(`=`, [`imageDigest`, imageDigest])}' \
  --output text)

batch_delete "${IMAGE_DIGESTS}"

# Find untagged images and delete them.
IMAGE_DIGESTS=$(aws ecr-public describe-images \
  --repository-name "${REPOSITORY_NAME}" \
  --query 'imageDetails[?!imageTags].{imageDigest: join(`=`, [`imageDigest`, imageDigest])}' \
  --output text)

batch_delete "${IMAGE_DIGESTS}"

