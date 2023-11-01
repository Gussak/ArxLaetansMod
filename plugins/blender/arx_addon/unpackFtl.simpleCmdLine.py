# Copyright 2023 Gussak<https://github.com/Gussak>
#
# This file is part of Arx Laetans Mod.
#
# Arx Libertatis is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Arx Libertatis is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Arx Libertatis. If not, see <http://www.gnu.org/licenses/>.

import sys
import ctypes

#help minimal code to let .ftl be unpacked
#help must be run from arx_addon folder
#help usage ex.: PYTHONPATH="${PYTHONPATH}:/$(pwd)" python3 unpackFtl.simpleCmdLine.py "<fullPathToFile.ftl>"

def FUNCUnpackFtl(strFileFullName):
    lib = ctypes.cdll.LoadLibrary("./libArxIO.so.0") #lib seems to be a restricted required name? renaming lib to libLoaded will just fail...
    from lib import ArxIO
    # lib.ArxIO_init()
    libArxIO = ArxIO()
    
    with open(strFileFullName, "rb") as flInput:
        dataPacked = flInput.read()
        if dataPacked[:3] == b"FTL":
            print("file is not packed")
        else:
            dataUnpacked = libArxIO.unpack(dataPacked)
            with open(strFileFullName + ".unpack", "wb") as flOutput:
                flOutput.write(dataUnpacked)
            print("packedSize=%i unpackedSize=%i" % (len(dataPacked), len(dataUnpacked)))

if __name__ == "__main__":
    FUNCUnpackFtl(str(sys.argv[1]))



