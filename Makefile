.PHONY: all clean test

all: check_vsphere_bundle check_vsphere

check_vsphere_bundle:
	pip install --no-cache-dir --no-compile --target allinone .
	mv allinone/bin/check_vsphere allinone/__main__.py
	python -m zipapp  -c -p '/usr/bin/env python3' allinone
	rm -rf allinone
	mv allinone.pyz check_vsphere_bundle

check_vsphere:
	mkdir build
	cp -av checkvsphere build/checkvsphere
	mv build/checkvsphere/cli.py build/__main__.py
	( cd build/; python -m zipapp -c --output ../check_vsphere -p '/usr/bin/env python3' . )
	rm -rf build

dist: pyproject.toml
	python3 -m build
	chmod a+r dist/*

.PHONY: clean
clean:
	rm -rf build allinone check_vsphere_bundle check_vsphere zip check_vsphere.zip build check_vsphere.egg-info dist

.PHONY: upload-test
upload-test: dist
	python3 -m twine upload --repository testpypi dist/*

.PHONY: upload-prod
upload-prod: dist
	python3 -m twine upload dist/*

.PHONY: upload-private
upload-private: dist
	rsync -avH dist/* cb:~/public_html/simple/checkvsphere
