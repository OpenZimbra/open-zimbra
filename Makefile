#!/usr/bin/make -f
# SPDX-License-Identifier: AGPL-3+

export BUILD_TARGET_DISTRO=ubuntu-focal-amd64
export BUILD_TARGET_APTREPO=$(CURDIR)/.aptrepo/default

help:
	@echo "LibreZimbra build sytem help"
	@echo "-----------------------------------------------------------------------------"
	@echo ""
	@echo "$(MAKE) clone                      - clone all git repositories"
	@echo "$(MAKE) build-deb                  - build the debian native packages"
	@echo "$(MAKE) build-legacy               - build the legacy build system packages"
	@echo "$(MAKE) finish-repo                - update the apt repository index"
	@echo ""
	@echo "$(MAKE) all                        - run the complete build process"
	@echo ""
	@echo "$(MAKE) clean                      - clean up everything"
	@echo ""
	@echo "$(MAKE) check-update-synacor       - check for updates from synacor repos"
	@echo "$(MAKE) check-update-librezimbra   - check for updates from librezimbra repos"
	@echo "-----------------------------------------------------------------------------"

# do it all - note that the order is important
all: clone build-deb build-legacy finish-repo

# clone repos
clone:
	@echo "cloning git repos"
	@env python do-clone.py

# build the debian native packages
build-deb:
	@echo "building deb packages"
	@env python do-build-deb.py

# build legacy packages (not debian native yet)
build-legacy:
	@echo "building legacy packages"
	@./start-build-container /bin/bash /home/build/src/do-build-legacy.sh

# update the apt repo index
finish-repo:
	@echo "updating apt repo index"
	@cd pkg/__dckbp__/ && \
            DCK_BUILDPACKAGE_TARGET_REPO=$(BUILD_TARGET_APTREPO) \
            ./dck-buildpackage --update-aptrepo --target $(BUILD_TARGET_DISTRO)

# check whether we missed an update from synacor
check-update-synacor:
	@for r in `cat cf/repos-zimbra` ; do ( \
            cd pkg/$$r && \
            if [ `git rev-list --left-right --count synacor/develop...HEAD | sed 's~\t.*~~'` != '0' ]; then \
                echo "new commits from synacor in pkg/$$r" ; \
            fi ; \
        ) ; done

check-update-librezimbra:
	@for r in `cat cf/repos-zimbra cf/repos-extra` ; do ( \
            cd pkg/$$r && \
            if [ `git rev-list --left-right --count librezimbra/develop...HEAD | sed 's~\t.*~~'` != '0' ]; then \
                echo "new commits from librezimbra in pkg/$$r" ; \
            fi ; \
        ) ; done

# clean up everything
clean:
	@rm -Rf .aptrepo .stat tmp build

.PHONY: all build-deb build-legacy finish-repo clean
