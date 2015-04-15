################################################################################
# executables
################################################################################

NPM_CHECK=node_modules/.bin/npm-check
MVERSION=node_modules/.bin/mversion
MOCHA=node_modules/.bin//mocha
_MOCHA=node_modules/.bin//_mocha
COVERALLS=node_modules/.bin/coveralls
ISTANBUL=node_modules/.bin/istanbul
BOWER=node_modules/.bin/bower
SPACEJAM=node_modules/.bin/spacejam

################################################################################
# variables
################################################################################

VERSION=`$(MVERSION) | sed -E 's/\* package.json: //g'`


################################################################################
# setup everything for development
################################################################################

setup:
	@npm install

################################################################################
# nodejs tests
################################################################################

# test code in nodejs
test:
	@$(MOCHA)

# test code in nodejs, and generates coverage
test.coverage:
	@$(ISTANBUL) cover $(_MOCHA)

# test code in nodejs, generates coverage and startup a simple server
test.coverage.preview: test.coverage
	@cd coverage/lcov-report && python -m SimpleHTTPServer 8080

# test code in nodejs, generates coverage and send it to coveralls
test.coverage.coveralls: test.coverage
	@cat coverage/lcov.info | $(COVERALLS)

################################################################################
# meteor tests
################################################################################

# run tests and show output in browser
test.meteor:
	meteor test-packages ./

# run tests and show output in terminal
test.meteor.headless:
	@$(SPACEJAM) test-packages ./

################################################################################
# more tests
################################################################################

test.all: test test.meteor.headless

################################################################################
# manages version bumps
################################################################################

bump.minor:
	@$(MVERSION) minor

bump.major:
	@$(MVERSION) major

bump.patch:
	@$(MVERSION) patch

################################################################################
# checking / updating dependencies
################################################################################

deps.check:
	@$(NPM_CHECK)

deps.upgrade:
	@$(NPM_CHECK) -u

################################################################################
# publish / re-publish
################################################################################

publish:
	git tag -a $(VERSION) -m "Releasing $(VERSION)"
	git push origin master --tags
	npm publish
	meteor

re-publish:
	git tag -d $(VERSION)
	git push origin :$(VERSION)
	git tag -a $(VERSION) -m "Releasing $(VERSION)"
	git push origin master -f --tags
	npm publish -f

################################################################################
# OTHERS
################################################################################

.PHONY: test