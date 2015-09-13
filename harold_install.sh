#!/usr/bin/env bash

HAROLD_FILES_DIR="$HOME/harold_files"
if [[ ! -d $HAROLD_FILES_DIR ]]; then
    echo "Creating $HAROLD_FILES_DIR..."
    mkdir -p $HAROLD_FILES_DIR
fi

HAROLD_DIR="$HOME/harold"
if [[ -d $HAROLD_DIR && ! -h $HAROLD_DIR ]]; then
    echo "Moving existing harold files..."
    mv "$HAROLD_DIR/*" "$HAROLD_FILES_DIR/."
    echo "Removing existing harold directory..."
    rm -rf $HAROLD_DIR
    echo "Symlinking harold_files directory..."
    ln -s $HAROLD_FILES_DIR $HAROLD_DIR
fi

HAROLD_MP3="$HOME/harold.mp3"
HAROLD_SELECTION="random"
if [[ -f $HAROLD_MP3 ]]; then
    echo "Copying existing harold.mp3 to harold_files"
    cp $HAROLD_MP3 "$HAROLD_FILES_DIR/."
    HAROLD_SELECTION="harold.mp3"
fi

HAROLD_SELECTION_FILE="$HOME/.harold"
if [[ ! -f $HAROLD_SELECTION_FILE ]]; then
    echo "Creating harold selection file"
    echo $HAROLD_SELECTION >> $HAROLD_SELECTION_FILE
fi

