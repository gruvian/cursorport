import sys
import subprocess
import os
from PyQt5.QtWidgets import QApplication, QFileDialog, QVBoxLayout, QPushButton, QLabel, QLineEdit, QWidget

class CursorInstallerApp(QWidget):
    def __init__(self):
        super().__init__()
        self.initUI()

    def initUI(self):
        self.setWindowTitle('Windows to Ubuntu Cursor Installer')

        layout = QVBoxLayout()

        self.label = QLabel('Select the folder with Windows cursors (.cur and .ani)')
        layout.addWidget(self.label)

        self.select_btn = QPushButton('Select Folder')
        self.select_btn.clicked.connect(self.select_folder)
        layout.addWidget(self.select_btn)

        self.dest_label = QLabel('Enter destination folder name:')
        layout.addWidget(self.dest_label)

        self.dest_input = QLineEdit(self)
        layout.addWidget(self.dest_input)

        self.install_btn = QPushButton('Convert and Install Cursors')
        self.install_btn.setEnabled(False)
        self.install_btn.clicked.connect(self.install_cursors)
        layout.addWidget(self.install_btn)

        self.setLayout(layout)

    def select_folder(self):
        folder = QFileDialog.getExistingDirectory(self, 'Select Cursor Folder')
        if folder:
            self.cursor_folder = folder
            self.label.setText(f'Selected folder: {folder}')
            self.install_btn.setEnabled(True)

    def install_cursors(self):
        dest_folder_name = self.dest_input.text()
        if not dest_folder_name:
            self.label.setText("Please enter a valid destination folder name.")
            return

        # Create the output directory if it doesn't exist
        output_dir = os.path.join(self.cursor_folder, "cursors")
        if not os.path.exists(output_dir):
            os.makedirs(output_dir)

        try:
            # Iterate over each file in the selected folder
            self.label.setText("Converting Windows cursors to Linux-compatible format...")
            for filename in os.listdir(self.cursor_folder):
                if filename.endswith(".cur") or filename.endswith(".ani"):
                    input_file = os.path.join(self.cursor_folder, filename)
                    subprocess.run(['win2xcur', input_file, '-o', output_dir], check=True)

            # Check if files were created in the output directory
            converted_files = os.listdir(output_dir)
            if not converted_files:
                self.label.setText(f"Error: No files generated in {output_dir}. Conversion failed.")
                return

            # Search for any Install.inf files in the output directory
            install_files = [f for f in os.listdir(self.cursor_folder) if "Install.inf" in f]

            if not install_files:
                self.label.setText(f"Error: No Install.inf file found in {output_dir}.")
                return

            # Run the bash script with sudo
            bash_script = "./cursor_setup.sh"
            subprocess.run(['sudo', 'bash', bash_script, self.cursor_folder, dest_folder_name], check=True)

            self.label.setText(f"Cursor installation completed in /usr/share/icons/{dest_folder_name}!")

        except subprocess.CalledProcessError as e:
            self.label.setText(f"Error during cursor conversion or installation: {str(e)}")




if __name__ == '__main__':
    app = QApplication(sys.argv)
    window = CursorInstallerApp()
    window.show()
    sys.exit(app.exec_())
