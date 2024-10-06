import subprocess
import os
from PyQt5 import QtWidgets

class CursorInstallerApp(QtWidgets.QWidget):
    def __init__(self):
        super().__init__()
        self.initUI()

    def initUI(self):
        self.setWindowTitle('Windows to Ubuntu Cursor Installer')

        layout = QtWidgets.QVBoxLayout()
        self.setLayout(layout)

        self.label = QtWidgets.QLabel('Select the folder with Windows cursors (.cur and .ani)')
        layout.addWidget(self.label)

        self.select_btn = QtWidgets.QPushButton('Select Folder')
        self.select_btn.clicked.connect(self.select_folder)
        layout.addWidget(self.select_btn)

        self.dest_label = QtWidgets.QLabel('Enter destination folder name:')
        layout.addWidget(self.dest_label)

        self.dest_input = QtWidgets.QLineEdit(self)
        layout.addWidget(self.dest_input)

        self.install_btn = QtWidgets.QPushButton('Convert and Install Cursors')
        self.install_btn.setEnabled(False)
        self.install_btn.clicked.connect(self.install_cursors)
        layout.addWidget(self.install_btn)

        self.show()

    def select_folder(self):
        folder = QtWidgets.QFileDialog.getExistingDirectory(self, 'Select Cursor Folder')
        if folder:
            self.cursor_folder = folder
            self.label.setText(f'Selected folder: {folder}')
            self.install_btn.setEnabled(True)

    def install_cursors(self):
        dest_folder_name = self.dest_input.text()
        if not dest_folder_name:
            self.label.setText("Please enter a valid destination folder name.")
            return

        output_dir = os.path.join(self.cursor_folder, "cursors")
        if not os.path.exists(output_dir):
            os.makedirs(output_dir)

        try:
            self.label.setText("Converting Windows cursors to Linux-compatible format...")
            for filename in os.listdir(self.cursor_folder):
                if filename.endswith(".cur") or filename.endswith(".ani"):
                    input_file = os.path.join(self.cursor_folder, filename)
                    subprocess.run(['win2xcur', input_file, '-o', output_dir], check=True)

            converted_files = os.listdir(output_dir)
            if not converted_files:
                self.label.setText(f"Error: No files generated in {output_dir}. Conversion failed.")
                return

            install_files = [f for f in os.listdir(self.cursor_folder) if "Install.inf" in f]

            if not install_files:
                self.label.setText(f"Error: No Install.inf file found in {output_dir}.")
                return

            bash_script = "./cursor_setup.sh"
            subprocess.run(['sudo', 'bash', bash_script, self.cursor_folder, dest_folder_name], check=True)

            self.label.setText(f"Cursor installation completed in /usr/share/icons/{dest_folder_name}!")

        except subprocess.CalledProcessError as e:
            self.label.setText(f"Error during cursor conversion or installation: {str(e)}")


app = QtWidgets.QApplication([])
window = CursorInstallerApp()
app.exec_()
