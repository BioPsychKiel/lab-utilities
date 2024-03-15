import shutil
from pathlib import Path

# Define your source and target directories and the substring
source_dir = Path(r'Y:\bids_projects\epoc_cn')
target_dir = Path(r'C:\Users\juliu\Desktop\data_epoc')
substring = 'restingstate'

# Create the target directory if it doesn't exist
target_dir.mkdir(parents=True, exist_ok=True)

# Search for files and copy them to the target directory
for file_path in source_dir.rglob(f'*{substring}*'):
    if file_path.is_file():
        shutil.copy(file_path, target_dir / file_path.name)

print(f'Files containing "{substring}" have been copied to {target_dir}')
