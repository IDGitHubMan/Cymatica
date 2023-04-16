from PyQt6.QtWidgets import QApplication, QWidget
import sys
import os
import csv
from PyQt6.QtCore import QSize, Qt
from PyQt6.QtWidgets import QApplication, QMainWindow, QPushButton

# Subclass QMainWindow to customize your application's main window


class MainWindow(QMainWindow):
    def __init__(self):
        here = os.path.dirname(os.path.abspath(__file__))
        queue = open(os.path.join(here, 'data/nowPlaying.csv'), "a+")
        states = open(os.path.join(here, 'data/states.csv'), "a+")
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
