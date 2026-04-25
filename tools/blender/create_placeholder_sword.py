import os

import bpy


ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
OUTPUT_PATH = os.path.join(ROOT, "assets", "weapons", "stone_sword_placeholder.glb")


def clear_scene():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete()


def material(name, color, metallic=0.0, roughness=0.65):
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    bsdf.inputs["Base Color"].default_value = color
    bsdf.inputs["Metallic"].default_value = metallic
    bsdf.inputs["Roughness"].default_value = roughness
    return mat


def shade_flat(obj):
    for polygon in obj.data.polygons:
        polygon.use_smooth = False


def add_bevel(obj, amount=0.025, segments=1):
    bevel = obj.modifiers.new("LowPolyBevel", "BEVEL")
    bevel.width = amount
    bevel.segments = segments
    bevel.affect = "EDGES"
    obj.modifiers.new("WeightedNormals", "WEIGHTED_NORMAL")


def make_blade(blade_mat):
    # The blade points along local -Z so it matches the Godot SwordPivot swing.
    base_z = -0.03
    tip_z = -1.38
    half_width_base = 0.12
    half_width_tip = 0.035
    half_thickness = 0.028
    vertices = [
        (0.0, 0.0, base_z),
        (half_width_base, 0.0, base_z),
        (0.0, half_thickness, base_z),
        (0.0, 0.0, tip_z),
        (half_width_tip, 0.0, tip_z),
        (0.0, half_thickness * 0.45, tip_z),
    ]
    faces = [
        (0, 1, 4, 3),
        (0, 3, 5, 2),
        (1, 2, 5, 4),
        (0, 2, 1),
        (3, 4, 5),
    ]
    mesh = bpy.data.meshes.new("StoneSwordBladeMesh")
    mesh.from_pydata(vertices, [], faces)
    mesh.update()
    obj = bpy.data.objects.new("Blade", mesh)
    obj.data.materials.append(blade_mat)
    bpy.context.collection.objects.link(obj)
    mirror = obj.modifiers.new("BladeSymmetry", "MIRROR")
    mirror.use_axis[0] = True
    mirror.use_axis[1] = True
    mirror.use_axis[2] = False
    add_bevel(obj, 0.018, 1)
    shade_flat(obj)
    return obj


def make_tang(mat):
    return add_cube("FullTang", (0.0, 0.0, 0.18), (0.07, 0.045, 0.72), mat, bevel_amount=0.006)


def add_cube(name, location, scale, mat, bevel_amount=0.02):
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=location)
    obj = bpy.context.object
    obj.name = name
    obj.dimensions = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    obj.data.materials.append(mat)
    add_bevel(obj, bevel_amount, 1)
    shade_flat(obj)
    return obj


def add_cylinder_z(name, location, radius, depth, mat, vertices=12, bevel_amount=0.012):
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices, radius=radius, depth=depth, location=location)
    obj = bpy.context.object
    obj.name = name
    obj.data.materials.append(mat)
    add_bevel(obj, bevel_amount, 1)
    shade_flat(obj)
    return obj


def add_sphere(name, location, radius, mat):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=8, radius=radius, location=location)
    obj = bpy.context.object
    obj.name = name
    obj.scale.z = 0.82
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    obj.data.materials.append(mat)
    shade_flat(obj)
    return obj


def add_wrap_band(name, z, mat):
    obj = add_cylinder_z(name, (0.0, 0.0, z), 0.076, 0.035, mat, vertices=12, bevel_amount=0.006)
    obj.scale.x = 1.06
    obj.scale.y = 0.86
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    return obj


def main():
    clear_scene()
    blade_mat = material("Brushed Iron", (0.72, 0.82, 0.9, 1.0), metallic=0.55, roughness=0.32)
    guard_mat = material("Warm Brass", (0.75, 0.54, 0.22, 1.0), metallic=0.25, roughness=0.48)
    grip_mat = material("Dark Leather", (0.18, 0.09, 0.045, 1.0), roughness=0.8)
    wrap_mat = material("Leather Wrap Highlight", (0.28, 0.16, 0.08, 1.0), roughness=0.82)

    root = bpy.data.objects.new("StoneSwordPlaceholder", None)
    bpy.context.collection.objects.link(root)

    parts = [
        make_blade(blade_mat),
        make_tang(blade_mat),
        add_cube("Crossguard", (0.0, 0.0, -0.015), (0.58, 0.105, 0.12), guard_mat, bevel_amount=0.028),
        add_cylinder_z("Grip", (0.0, 0.0, 0.275), 0.065, 0.52, grip_mat, vertices=12, bevel_amount=0.012),
        add_wrap_band("GripWrapA", 0.09, wrap_mat),
        add_wrap_band("GripWrapB", 0.19, wrap_mat),
        add_wrap_band("GripWrapC", 0.29, wrap_mat),
        add_wrap_band("GripWrapD", 0.39, wrap_mat),
        add_sphere("Pommel", (0.0, 0.0, 0.545), 0.105, guard_mat),
    ]
    for part in parts:
        part.parent = root

    bpy.ops.object.empty_add(type="PLAIN_AXES", location=(0.0, 0.0, 0.0))
    pivot_marker = bpy.context.object
    pivot_marker.name = "SwordPivotMarker"
    pivot_marker.parent = root

    os.makedirs(os.path.dirname(OUTPUT_PATH), exist_ok=True)
    bpy.ops.export_scene.gltf(
        filepath=OUTPUT_PATH,
        export_format="GLB",
        use_selection=False,
        export_apply=True,
    )


if __name__ == "__main__":
    main()
