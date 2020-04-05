all:
	echo "Use publish to send the package on pypi"

clean_dist:
	rm -rf dist

dist: clean_dist
	python3 setup.py bdist_wheel

publish: dist
	twine upload dist/*

.PHONY: clean_dist
