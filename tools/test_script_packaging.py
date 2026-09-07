"""Exercise the production materialization target without the game's toolchain.

Usage: python tools/test_script_packaging.py /path/to/cmake /path/to/ninja
"""
import pathlib
import subprocess
import sys
import tempfile

root = pathlib.Path(__file__).resolve().parents[1]
cmake, ninja = map(str, sys.argv[1:3])
source = (root / "CMakeLists.txt").read_text()
start = source.index("add_custom_target(${MOD_SLUG}.scripts ALL")
end = source.index("\nconfigure_folder_file", start)
target = source[start:end]

with tempfile.TemporaryDirectory(prefix="mod-settings-packaging-") as temporary:
    work = pathlib.Path(temporary)
    scripts = work / "scripts"
    scripts.mkdir()
    (scripts / "first.reds").write_text("// first version\n")
    (work / "header.txt").write_text("Test package\n")
    (work / "module-source.reds").write_text("module ModSettings\n")
    (work / "CMakeLists.txt").write_text(
        'cmake_minimum_required(VERSION 3.24)\nproject(test NONE)\n'
        'set(MOD_SLUG mod_settings)\n'
        'set(MOD_REDSCRIPT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/scripts")\n'
        'set(MOD_HEADER_TXT_FILE "${CMAKE_CURRENT_SOURCE_DIR}/header.txt")\n'
        'set(MOD_GAME_DIR_RED4EXT_MOD_DIR "${CMAKE_BINARY_DIR}/game")\n'
        'set(MOD_GAME_DIR_RED4EXT_PACKED_FILE "${MOD_GAME_DIR_RED4EXT_MOD_DIR}/packed.reds")\n'
        'set(MOD_GAME_DIR_RED4EXT_MODULE_FILE "${MOD_GAME_DIR_RED4EXT_MOD_DIR}/module.reds")\n'
        f'set(CYBERPUNK_CMAKE_SCRIPTS "{(root / "deps/cpcmake/scripts").as_posix()}")\n'
        'configure_file(module-source.reds mod_settings.module.reds COPYONLY)\n'
        'add_custom_target(mod_settings)\n'
        'add_custom_target(mod_settings.packed.reds)\n'
        'add_custom_target(mod_settings.module.reds)\n' + target
    )
    build = work / "build"
    subprocess.run([cmake, "-S", str(work), "-B", str(build), "-G", "Ninja",
                    f"-DCMAKE_MAKE_PROGRAM={ninja}"], check=True)

    def pack():
        subprocess.run([cmake, "--build", str(build), "--target", "mod_settings"], check=True)
        assert (build / "game/module.reds").read_text() == "module ModSettings\n"
        return (build / "game/packed.reds").read_text()

    assert "first version" in pack()
    (scripts / "first.reds").write_text("// changed version\n")
    assert "changed version" in pack()
    (scripts / "second.reds").write_text("// added script\n")
    assert "added script" in pack()
    (scripts / "first.reds").unlink()
    packed = pack()
    assert "changed version" not in packed and "added script" in packed
print("PASS: initial, edited, added and removed scripts; no DLL relink required.")
