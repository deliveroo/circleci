#!/bin/bash
set -ex

command -v ci
command -v clean_up_reusable_docker
command -v ensure_head
command -v print_env
command -v push_image_to_ecr
command -v push_image_to_docker_hub
command -v pull_image_from_ecr
command -v comment_on_pr
command -v parse_scan_results
command -v scan_container_vulnerabilities
command -v vulnerabilities_scanner
command -v push_lambda
command -v wfi

docker-compose version
docker --version
python3 --version
aws --version
