### Environment setup ###
SHELL:=/bin/bash

TERM ?= 'dumb'
pwd:=$(shell pwd)
ifdef mounted_orchestration
  orchestration_dir=$(mounted_orchestration)
else
  orchestration_dir=${pwd}/orchestration
endif

ifdef env_file
  custom_env_file ?= 1
else
  custom_env_file ?= 0
endif

ifneq (,$(wildcard ${pwd}/config/database.yml))
  database_enabled = 1
else
  database_enabled = 0
endif

make=$(MAKE) $1
orchestration_config_filename:=.orchestration.yml
orchestration_config:=${pwd}/${orchestration_config_filename}
print_error=printf '${red}\#${reset} '$1 | tee '${stderr}'
println_error=$(call print_error,$1'\n')
print=printf '${blue}\#${reset} '$1
println=$(call print,$1'\n')
printraw=printf $1
printrawln=$(call printraw,$1'\n')
stdout=${pwd}/log/orchestration.stdout.log
stderr=${pwd}/log/orchestration.stderr.log
log_path_length=$(shell echo "${stdout}" | wc -c)
ifndef verbose
log_tee:= 2>&1 | tee -a ${stdout}
log:= >>${stdout} 2>>${stderr}
progress_point:=perl -e 'while( my $$line = <STDIN> ) { printf("."); select()->flush(); }'
log_progress:= > >(tee -ai ${stdout} >&1 | ${progress_point}) 2> >(tee -ai ${stderr} 2>&1 | ${progress_point})
endif
red:=$(shell tput setaf 1)
green:=$(shell tput setaf 2)
yellow:=$(shell tput setaf 3)
blue:=$(shell tput setaf 4)
magenta:=$(shell tput setaf 5)
cyan:=$(shell tput setaf 6)
gray:=$(shell tput setaf 7)
reset:=$(shell tput sgr0)
tick=[${green}✓${reset}]
cross=[${red}✘${reset}]
warn=[${yellow}!${reset}]
hr=$(call println,"$1$(shell head -c ${log_path_length} < /dev/zero | tr '\0' '=')${reset}")
managed_env_tag:=\# -|- ORCHESTRATION
standard_env_path:=${pwd}/.env
backup_env_path:=${pwd}/.env.orchestration.backup
is_managed_env:=$$(test -f '${standard_env_path}' && tail -n 1 '${standard_env_path}') == "${managed_env_tag}"*
token:=$(shell cat /dev/urandom | LC_CTYPE=C tr -dc 'a-z0-9' | fold -w8 | head -n1)
back_up_env:=( \
               [ ! -f '${standard_env_path}' ] \
             || \
               ( \
                 [ -f '${standard_env_path}' ] \
                 && cp '${standard_env_path}' '${backup_env_path}' \
               ) \
             )

replace_env:=( \
               ( [ "${custom_env_file}" == "0" ] ) \
             || \
               ( \
                 [ "${custom_env_file}" == "1" ] \
                 && ${back_up_env} \
                 && cp ${env_file} '${standard_env_path}' \
                 && $(call printraw,'\n${managed_env_tag}') >> '${standard_env_path}' \
               ) \
             )

restore_env:=( \
               ( \
                 [[ ! ${is_managed_env} ]] \
                 || [ ! -f '${backup_env_path}' ] \
               ) \
             || \
               ( \
                 [ -f '${backup_env_path}' ] \
                 && [[ ${is_managed_env} ]] \
                 && mv '${backup_env_path}' '${standard_env_path}' \
               ) \
             )

key_chars:=[a-zA-Z0-9_]
censored:=**********
censor=s/\(^${key_chars}*$(1)${key_chars}*\)=\(.*\)$$/\1=${censored}/
censor_urls:=s|\([a-zA-Z0-9_+]\+://.*:\).*\(@.*\)$$|\1${censored}\2|
format_env:=sed '$(call censor,SECRET); \
                 $(call censor,TOKEN); \
                 $(call censor,PRIVATE); \
                 $(call censor,KEY); \
                 $(censor_urls); \
                 /^\s*$$/d; \
                 /^\s*\#/d; \
                 s/\(^[a-zA-Z0-9_]\+\)=/${blue}\1${reset}=/; \
                 s/^/  /; \
                 s/=\(.*\)$$/=${yellow}\1${reset}/' | \
            sort

fail=( \
       $(call printraw,' ${cross}') ; \
       ${restore_env} ; \
       $(call make,dump) ; \
       echo ; \
       $(call println,'Failed. ${cross}') ; \
       exit 1 \
    )


ifdef env_file
  -include ${env_file}
else
ifneq (${env},test)
ifeq (,$(findstring test,$(MAKECMDGOALS)))
  -include .env
endif
endif
endif

export

ifneq (,$(env))
  # `env` set by current shell.
else ifneq (,$(RAILS_ENV))
  env=$(RAILS_ENV)
else ifneq (,$(RACK_ENV))
  env=$(RACK_ENV)
else
  env=development
endif

DOCKER_TAG ?= latest

ifneq (,$(wildcard ./Gemfile))
  rake=RACK_ENV=${env} RAILS_ENV=${env} bundle exec rake
else
  rake=RACK_ENV=${env} RAILS_ENV=${env} rake
endif

ifneq (,$(wildcard ${env_file}))
  rake_cmd:=${rake}
  rake=. ${env_file} && ${rake_cmd}
endif

ifeq (,$(findstring serve,$(MAKECMDGOALS)))
ifeq (,$(findstring console,$(MAKECMDGOALS)))
ifeq (,$(findstring test,$(MAKECMDGOALS)))
  docker_config:=$(shell RAILS_ENV=development bundle exec rake orchestration:config)
  docker_organization=$(word 1,$(docker_config))
  docker_repository=$(word 2,$(docker_config))
endif
endif
endif

ifeq (,$(project_name))
  project_base = ${docker_repository}_${env}
else
  project_base := $(project_name)
endif

ifeq (,$(findstring deploy,$(MAKECMDGOALS)))
  sidecar_suffix := $(shell test -f ${orchestration_dir}/.sidecar && cat ${orchestration_dir}/.sidecar)
  ifneq (,${sidecar_suffix})
    sidecar := 1
  endif

  ifdef sidecar
    # Set the variable to an empty string so that "#{sidecar-1234}" will
    # evaluate to "1234" in port mappings.
    sidecar_compose = sidecar=''
    ifeq (,${sidecar_suffix})
      sidecar_suffix := $(call token)
      _ignore := $(shell echo ${sidecar_suffix} > ${orchestration_dir}/.sidecar)
    endif

    ifeq (,${sidecar_suffix})
      $(warning Unable to generate project suffix; project name collisions may occur.)
    endif
    compose_project_name = ${project_base}_${sidecar_suffix}
  else
    compose_project_name = ${project_base}
  endif
else
  compose_project_name = ${project_base}
endif

compose_base=env -i \
             PATH=$(PATH) \
             HOST_UID=$(shell id -u) \
             DOCKER_ORGANIZATION="${docker_organization}" \
             DOCKER_REPOSITORY="${docker_repository}" \
             COMPOSE_PROJECT_NAME="${compose_project_name}" \
	     ${sidecar_compose} \
             docker-compose \
             -f ${orchestration_dir}/docker-compose.${env}.yml

git_branch ?= $(if $(branch),$(branch),$(shell git rev-parse --abbrev-ref HEAD))
ifndef dev
  git_version ?= $(shell git rev-parse --short --verify ${git_branch})
else
  git_version = dev
endif

docker_image=${docker_organization}/${docker_repository}:${git_version}

compose=${compose_base}
random_str=cat /dev/urandom | LC_ALL=C tr -dc 'a-z' | head -c $1

ifneq (,$(wildcard ${orchestration_dir}/docker-compose.local.yml))
  compose:=${compose} -f ${orchestration_dir}/docker-compose.local.yml
endif

all: build

### Container management commands ###

.PHONY: start
ifndef network
start: network := ${compose_project_name}
endif
start: _create-log-directory _clean-logs
	@$(call print,'${yellow}Starting ${cyan}${env}${yellow} containers${reset} ...')
ifeq (${env},$(filter ${env},test development))
	@${compose} up --detach --force-recreate --renew-anon-volumes --remove-orphans ${services} ${log} || ${fail}
	@[ -n '${sidecar}' ] && \
         ( \
           $(call printraw,' ${yellow}(joining dependency network ${green}${network}${yellow})${reset} ... ') ; \
           docker network connect '${network}' '$(shell hostname)' ${log} \
           || ( \
           $(call println,'') ; \
           $(call println,'${yellow}Warning${reset}: Unable to join network: "${yellow}${network}${reset}". Container will not be able to connect to dependency services.') ; \
           $(call print,'You may need to delete "${yellow}orchestration/.sidecar${reset}" to disable sidecar mode if this file was added by mistake.\n...') ; \
           ) \
         ) \
         || ( [ -z '${sidecar}' ] || ${fail} )
else
	@${compose} up --detach --scale app=$${instances:-1} ${log} || ${fail}
endif
	@$(call printrawln,' ${green}started${reset} ${tick}')
	@$(call println,'${yellow}Waiting for services to become available${reset} ...')
	@$(call make,wait) 2>${stderr} || ${fail}

.PHONY: start-database
start-database:
	@$(call make,start services='database')

.PHONY: start-rabbitmq
start-rabbitmq:
	@$(call make,start services='rabbitmq')

.PHONY: start-app
start-app:
	@$(call make,start services='app')


.PHONY: stop
stop: network := ${compose_project_name}
stop:
	@$(call print,'${yellow}Stopping ${cyan}${env}${yellow} containers${reset} ...')
	@if docker ps --format "{{.ID}}" | grep -q $(shell hostname) ; \
          then \
            ( docker network disconnect ${network} $(shell hostname) ${log} || : ) \
            && \
            ( ${compose} down ${log} || ${fail} ) ; \
          else \
            ${compose} down ${log} || ${fail} ; \
          fi
	@$(call printrawln,' ${green}stopped${reset}. ${tick}')

.PHONY: logs
logs:
	@${compose} logs -f

.PHONY: config
config:
	@${compose} config

.PHONY: compose
compose:
	@echo ${compose}

### Development/Test Utility Commands

.PHONY: serve
serve: env_file ?= ./.env
serve: rails = RAILS_ENV='${env}' bundle exec rails server ${server}
serve:
	@if [ -f "${env_file}" ] ; \
         then ( \
                $(call println,'${yellow}Environment${reset}: ${green}${env_file}${reset}') && \
                cat '${env_file}' | ${format_env} && \
                $(call printrawln,'') \
            ) ; \
        fi
	${rails}

.PHONY: console
console: env_file ?= ./.env
console: rails = RAILS_ENV='${env}' bundle exec rails
console:
	@if [ -f "${env_file}" ] ; \
         then ( \
                $(call println,'${yellow}Environment${reset}: ${green}${env_file}${reset}') && \
                cat '${env_file}' | ${format_env} && \
                $(call printrawln,'') \
            ) ; \
        fi
	${rails} console

.PHONY: test-setup
test-setup: env := test
test-setup:
ifndef light
	@$(call make,start env=test)
  ifneq (,$(wildcard config/database.yml))
	${rake} db:create || :
    ifneq (,$(wildcard db/structure.sql))
	${rake} db:structure:load
    else ifneq (,$(wildcard db/schema.rb))
	${rake} db:schema:load
    endif

	${rake} db:migrate
  endif
endif

.PHONY: dump
dump:
ifndef verbose
	@$(call println)
	@$(call println,'${yellow}Captured${reset} ${green}stdout${reset} ${yellow}and${reset} ${red}stderr${reset} ${yellow}log data [${cyan}${env}${yellow}]${reset}:')
	@$(call println)
	@echo
	@test -f '${stdout}' && ( \
          $(call hr,${green}) ; \
          $(call println,'${gray}${stdout}${reset}') ; \
          $(call hr,${green}) ; \
          echo ; cat '${stdout}' ; echo ; \
          $(call hr,${green}) ; \
        )

	@test -f '${stdout}' && ( \
          echo ; \
          $(call hr,${red}) ; \
          $(call println,'${gray}${stderr}${reset}') ; \
          $(call hr,${red}) ; \
          echo ; cat '${stderr}' ; echo ; \
          $(call hr,${red}) ; \
        )
endif
ifneq (,$(findstring deploy,$(MAKECMDGOALS)))
	@echo ; \
        $(call hr,${yellow}) ; \
        $(call println,'${gray}docker-compose logs${reset}') ; \
        $(call hr,${yellow}) ; \
        echo
	@${compose} logs
	@echo ; \
        $(call hr,${yellow})
endif
	@$(NOOP)

.PHONY: image
image:
	@echo ${docker_image}

### Deployment utility commands ###

.PHONY: deploy
ifdef env_file
deploy: env_file_option = --env-file ${env_file}
endif
deploy: RAILS_ENV := ${env}
deploy: RACK_ENV := ${env}
deploy: DOCKER_TAG = ${git_version}
deploy: base_vars = DOCKER_ORGANIZATION=${docker_organization} DOCKER_REPOSITORY=${docker_repository} DOCKER_TAG=${git_version}
deploy: compose_deploy := ${base_vars} COMPOSE_PROJECT_NAME=${project_base} HOST_UID=$(shell id -u) docker-compose ${env_file_option} --project-name ${project_base} -f orchestration/docker-compose.production.yml
deploy: compose_config := ${compose_deploy} config
deploy: deploy_cmd := echo "$${config}" | ssh "${manager}" "/bin/bash -lc 'cat | docker stack deploy --prune --with-registry-auth -c - ${project_base}'"
deploy: out_of_sequence_error := rpc error: code = Unknown desc = update out of sequence
deploy: retry_message := ${yellow}Detected Docker RPC error: ${red}${out_of_sequence_error}${yellow}. Retrying in
deploy:
ifndef manager
	@$(call println_error,'Missing `manager` parameter: `make deploy manager=swarm-manager.example.com`') ; exit 1
endif
	@$(call println,'${yellow}Deploying ${green}${env} ${yellow}stack via ${green}${manager} ${yellow}as ${green}${project_base}${reset} ...') && \
          ( \
             $(call println,'${yellow}Deployment environment${reset}:') && \
             ( test -f '${env_file}' && cat '${env_file}' | ${format_env} || : ) && \
             $(call println,'') && \
             $(call println,'${yellow}Application image${reset}: ${cyan}${docker_image}${reset}') && \
             export config="$$(${compose_config} 2>${stderr})" ; \
             config_exit_code=$$? ; \
             if [[ "$${config_exit_code}" != "0" ]]; then exit ${config_exit_code}; fi ; \
             output="$$(${deploy_cmd} | tee)" ; \
             deploy_exit_code=$$? ; \
             if [[ "$${deploy_exit_code}" == 0 ]] ; then exit 0 ; fi ; \
             if ! echo "$${output}" | grep -q '${out_of_sequence_error}' ; then exit ${deploy_exit_code} ; fi ; \
             retry_in="$$(( 10 + RANDOM % 50 ))" ; \
             echo "${retry_message} ${green}$${retry_in} ${yellow}seconds.${reset}" ; \
             sleep "$${retry_in}" ; \
             ${deploy_cmd} \
          ) \
          || ${fail}

	@$(call println,'${yellow}Deployment${reset} ${green}complete${reset}. ${tick}')

.PHONY: rollback
ifndef service
rollback: service = app
endif
rollback:
ifndef manager
	@$(call println_error,'Missing `manager` parameter: `make deploy manager=swarm-manager.example.com`') ; exit 1
endif
	@$(call println,'${yellow}Rolling back${reset} ${green}${compose_project_name}_${service}${reset} ${yellow}via${reset} ${green}${manager}${reset} ...')
	@ssh "${manager}" 'docker service rollback --detach "${compose_project_name}_${service}"' ${log} || ${fail}
	@$(call println,'${yellow}Rollback request${reset} ${green}complete${reset}. ${tick}')

### Service healthcheck commands ###

.PHONY: wait
wait:
	@${rake} orchestration:wait
	@$(call println,'${yellow}All services${reset} ${green}ready${reset}. ${tick}')

## Generic Listener healthcheck for TCP services ##

wait-listener:
	@${rake} orchestration:listener:wait service=${service} sidecar=${sidecar}

### Docker build commands ###

.PHONY: build
build: build_dir = ${orchestration_dir}/.build
build: context = ${build_dir}/context.tar
build: _create-log-directory check-local-changes
	@$(call print,'${yellow}Preparing build context from${reset} ${cyan}${git_branch}:${git_version}${reset} ... ')
	@mkdir -p ${orchestration_dir}/.build ${log} || ${fail}
ifndef dev
	@git show ${git_branch}:./Gemfile > ${orchestration_dir}/.build/Gemfile 2>${stderr} || ${fail}
	@git show ${git_branch}:./Gemfile.lock > ${orchestration_dir}/.build/Gemfile.lock 2>${stderr} || ${fail}
	@git show ${git_branch}:./package.json > ${orchestration_dir}/.build/package.json 2>${stderr} || ${fail}
	@git show ${git_branch}:./yarn.lock > ${orchestration_dir}/.build/yarn.lock 2>${stderr} || ${fail}
	@git archive --format 'tar' -o '${context}' '${git_branch}' ${log} || ${fail}
else
	@tar -cvf '${context}' . ${log} || ${fail}
endif
	@$(call printrawln,'${green}complete.${reset} ${tick}')
ifdef include
	@$(call print,'${yellow}Including files from:${reset} ${cyan}${include}${reset} ...')
	@(while read line; do \
            export line; \
            include_dir="${build_dir}/$$(dirname "$${line}")/" && \
            mkdir -p "$${include_dir}" && cp "$${line}" "$${include_dir}" \
            && (cd '${orchestration_dir}/.build/' && tar rf 'context.tar' "$${line}"); \
          done < '${include}') ${log} || ${fail}
	@$(call printrawln,' ${green}complete.${reset} ${tick}')
endif
ifdef sidecar
        # Assume we are in a line-buffered environment (e.g. Jenkins)
	@$(call println,'${yellow}Building image${reset} ...')
else
	@$(call print,'${yellow}Building image${reset} ...')
endif
	@docker build \
                        --build-arg BUNDLE_GITHUB__COM \
                        --build-arg BUNDLE_BITBUCKET__ORG \
                        --build-arg GIT_COMMIT='${git_version}' \
                        -t ${docker_organization}/${docker_repository} \
                        -t ${docker_organization}/${docker_repository}:${git_version} \
                        ${orchestration_dir}/ ${log_progress} || ${fail}
	@$(call printrawln,' ${green}complete${reset}. ${tick}')
	@$(call println,'[${green}tag${reset}] ${cyan}${docker_organization}/${docker_repository}${reset}')
	@$(call println,'[${green}tag${reset}] ${cyan}${docker_organization}/${docker_repository}:${git_version}${reset}')

.PHONY: push
push: _create-log-directory
	@$(call print,'${yellow}Pushing${reset} ${cyan}${docker_image}${reset} ...')
	@docker push ${docker_image} ${log_progress} || ${fail}
	@$(call printrawln,' ${green}complete${reset}. ${tick}')

.PHONY: check-local-changes
check-local-changes:
ifndef dev
	@if [[ ! -z "$$(git status --porcelain)" ]] ; \
         then \
           $(call println,'${red}You have uncommitted changes which will not be included in your build:${reset}') ; \
           git status --porcelain ; \
           $(call println,'${yellow}Use ${cyan}make build dev=1${reset} ${yellow}to include these files.${reset}\n') ; \
         fi
endif

### Internal Commands ###
#
.PHONY: _clean-logs
_clean-logs:
	@rm -f '${stdout}' '${stderr}'
	@touch '${stdout}' '${stderr}'

.PHONY: _create-log-directory
_create-log-directory:
	@mkdir -p log
