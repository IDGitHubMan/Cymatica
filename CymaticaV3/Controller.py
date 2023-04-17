from PyQt6.QtWidgets import QApplication, QWidget
import sys
import json
import os
import csv
from PyQt6.QtCore import QSize, Qt
from PyQt6.QtWidgets import QApplication, QMainWindow, QPushButton

# Subclass QMainWindow to customize your application's main window


class MainWindow(QMainWindow):
    def __init__(self):
        here = os.path.dirname(os.path.abspath(__file__))
        queue = open(os.path.join(here, 'data/queue.txt'), "w")
        try:
            library = open(os.path.join(here, 'data/library.csv'), "r")
        except OSError as error:
            with open(os.path.join(here, 'data/library.csv'), "a") as library:
                fieldnames = ["Title", "Path", "Album", "Artist", "Genre", "ArtPath", "LeftR", "LeftG", "LeftB", "LeftA", "RightR", "RightG", "RightB", "RightA", "MixR", "MixG",
                              "MixB", "MixA", "Laser", "Spark", "Line", "LaserMin", "LaserMax", "LaserThreshold", "SparkMin", "SparkMax", "SparkThreshold", "LineMin", "LineMax", "LineThreshold"]
                writer = csv.DictWriter(queue, fieldnames=fieldnames)
                writer.writeheader()
        try:
            states = open(os.path.join(here, 'data/states.csv'), "r")
        except OSError as error:
            with open(os.path.join(here, 'data/states.json'), "w") as states:
                defaults = {"Visualizer": "basic", "VisualizerSpeciation": 0, "overlay": "none",
                            "playing": False, "loop": 0, "volume": 1, "diffChannels": True, "basicSettings": {"extraEllipses": False, "waveformLimit": 0.5, "ellipseLimit": 0.3}, "irisSettings": {"rotation": True, "lowerBound": 0, "upperBound": 86, "hollow": True, "shapeType": "line"}}
                ob = json.dumps(defaults)
                states.write(ob)
        try:
            os.makedirs(os.path.join(here, 'data/Library/Music'))
            os.makedirs(os.path.join(here, 'data/Library/Artwork'))
        except OSError as error:
            print("Folder is already made!")
        super().__init__()
        self.setWindowTitle("Cymatica")
        button = QPushButton("Press Me!")

        self.setMinimumSize(QSize(600, 600))

        # Set the central widget of the Window.
        self.setCentralWidget(button)


app = QApplication(sys.argv)

window = MainWindow()
window.show()

app.exec()
