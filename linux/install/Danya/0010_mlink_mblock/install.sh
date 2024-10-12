#!/bin/bash

sudo dpkg – i mLink-1.2.0-amd64.deb

sudo systemctl enable mblock-mlink

sudo mblock-mlink start