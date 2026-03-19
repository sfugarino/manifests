#!/bin/bash

helm upgrade --install docling-serve extreme-structure/docling-serve --version 0.1.1 -f values.yaml --namespace docling --create-namespace
