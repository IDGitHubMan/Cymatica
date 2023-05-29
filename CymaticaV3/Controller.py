from PyQt6.QtWidgets import QApplication, QWidget
import sys
import json
import eyed3
import os
import csv
from PyQt6.QtCore import QSize, pyqtSlot
from PyQt6.QtWidgets import QApplication, QMainWindow, QPushButton, QFileDialog
import shutil
import random

# Subclass QMainWindow to customize your application's main window


class MainWindow(QMainWindow):
    def __init__(self):
        here = os.path.dirname(os.path.abspath(__file__))
        try:
            queue = open(os.path.join(here, 'data/queue.txt'), "r")
        except OSError as error:
            open(os.path.join(here, 'data/queue.txt'), "w")
        try:
            library = open(os.path.join(here, 'data/library.csv'), "r")
        except OSError as error:
            with open(os.path.join(here, 'data/library.csv'), "a") as library:
                fieldnames = ["Title", "OrigPath", "LocalPath", "Album", "Artist", "Genre", "ArtPath", "LeftR", "LeftG", "LeftB", "LeftA", "RightR", "RightG", "RightB", "RightA", "MixR", "MixG",
                              "MixB", "MixA", "BG1R", "BG1G", "BG1B", "BG1A", "BG2R", "BG2G", "BG2B", "BG2A", "Laser", "Spark", "Line", "LaserMin", "LaserMax", "LaserThreshold", "SparkMin", "SparkMax", "SparkThreshold", "LineMin", "LineMax", "LineThreshold"]
                writer = csv.DictWriter(library, fieldnames=fieldnames)
                writer.writeheader()
        try:
            states = open(os.path.join(here, 'data/states.json'), "r")
        except OSError as error:
            with open(os.path.join(here, 'data/states.json'), "w") as states:
                defaults = {"Visualizer": 0, "VisualizerSpeciation": 0, "bgVolLerp": True, "overlay": 0, "overlaySpace": 10,
                            "playing": False, "loop": 0, "volume": 1, "diffChannels": True, "basicSettings": {"extraEllipses": False, "waveformLimit": 0.5, "ellipseLimit": 0.3}, "irisSettings": {"rotation": True, "lowerBound": 0, "upperBound": 86, "hollow": True, "shapeType": 0}}
                ob = json.dumps(defaults)
                states.write(ob)
        try:
            os.makedirs(os.path.join(here, 'data/Library/Music'))
            os.makedirs(os.path.join(here, 'data/Library/Artwork'))
        except OSError as error:
            print("Folder is already made!")
        super().__init__()
        self.setWindowTitle("Cymatica")
        button = QPushButton("Add Song")

        self.setMinimumSize(QSize(600, 600))

        # Set the central widget of the Window.
        self.setCentralWidget(button)
        button.clicked.connect(self.local_add)

    @pyqtSlot()
    def local_add(self):
        here = os.path.dirname(os.path.abspath(__file__))
        fname = QFileDialog.getOpenFileName(
            self,
            "Open File",
            "${HOME}",
            "Audio Files (*.mp3)",
        )
        a = eyed3.load(fname[0])
        shutil.copy(fname[0], os.path.join(
            here, 'data/Library/Music'))
        print()
        if a.tag.title != "" or a.tag.title != " ":
            with open(os.path.join(here, 'data/library.csv'), "a") as library:
                writer = csv.writer(library, delimiter=',', quotechar='"')
                r = random.randint(0, 255)
                g = random.randint(0, 255)
                b = random.randint(0, 255)
                writer.writerow([a.tag.title, fname[0], os.path.join(
                    here, 'data/Library/Music' + fname[0][fname[0].rindex("/"): len(fname[0])]), a.tag.album, a.tag.artist, a.tag.genre, "", r, g, b, 255, 255-r, 255-g, 255-b, 255, 255, 255, 255, 255, 255-r, 255-g, 255-b, 255, r, g, b, 255, 0, 1, 1, 0, 20, 40, 50, 100, 10, 50, 100, 10])
        else:
            with open(os.path.join(here, 'data/library.csv'), "a") as library:
                writer = csv.writer(library, delimiter=',', quotechar='"')
                r = random.randint(0, 255)
                g = random.randint(0, 255)
                b = random.randint(0, 255)
                writer.writerow([fname[0][fname[0].rindex("/"): -4], fname[0], os.path.join(
                    here, 'data/Library/Music' + fname[0][fname[0].rindex("/"): len(fname[0])]), a.tag.album, a.tag.artist, a.tag.genre, "", r, g, b, 255, 255-r, 255-g, 255-b, 255, 255, 255, 255, 255, 255-r, 255-g, 255-b, 255, r, g, b, 255, 0, 1, 1, 0, 20, 40, 50, 100, 10, 50, 100, 10])


app = QApplication(sys.argv)

window = MainWindow()
window.show()

app.exec()
