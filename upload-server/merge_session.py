"""Merge multiple PowerPoint files into one, preserving slides and media.

Usage:
    python merge_session.py output.pptx input1.pptx input2.pptx ...

The first input is the base (keeps its theme/masters). Slides from all
subsequent inputs are appended in order.
"""

import sys
import copy
from pathlib import Path
from pptx import Presentation
from pptx.opc.constants import RELATIONSHIP_TYPE as RT

# Relationship types to skip (already present from destination layout/master)
SKIP_RELTYPES = {
    RT.SLIDE_LAYOUT,
    RT.SLIDE_MASTER,
    RT.THEME,
}


def merge_presentations(output_path, input_paths):
    """Merge all input presentations into one output file."""
    if not input_paths:
        print("No input files provided")
        sys.exit(1)

    dst = Presentation(input_paths[0])

    for pptx_path in input_paths[1:]:
        print(f"  Adding: {pptx_path}")
        src = Presentation(pptx_path)

        for src_slide in src.slides:
            # Find best matching layout in destination
            src_layout_name = src_slide.slide_layout.name
            dst_layout = dst.slide_layouts[0]
            for layout in dst.slide_layouts:
                if layout.name == src_layout_name:
                    dst_layout = layout
                    break

            dst_slide = dst.slides.add_slide(dst_layout)

            # Remove default placeholder shapes
            for ph in list(dst_slide.placeholders):
                dst_slide.shapes._spTree.remove(ph._element)

            # Copy slide content (shapes, background, etc.)
            src_cSld = src_slide._element.find(
                '{http://schemas.openxmlformats.org/presentationml/2006/main}cSld'
            )
            dst_cSld = dst_slide._element.find(
                '{http://schemas.openxmlformats.org/presentationml/2006/main}cSld'
            )
            if src_cSld is not None and dst_cSld is not None:
                dst_slide._element.replace(dst_cSld, copy.deepcopy(src_cSld))

            # Copy media relationships (images, embedded objects)
            for rel in src_slide.part.rels.values():
                if rel.reltype in SKIP_RELTYPES:
                    continue
                if rel.is_external:
                    dst_slide.part.rels.get_or_add_ext_rel(
                        rel.reltype, rel.target_ref
                    )
                else:
                    try:
                        dst_slide.part.rels.get_or_add(
                            rel.reltype, rel.target_part
                        )
                    except Exception:
                        pass

    dst.save(output_path)
    print(f"  Saved: {output_path} ({len(dst.slides)} slides)")


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print(f"Usage: {sys.argv[0]} output.pptx input1.pptx [input2.pptx ...]")
        sys.exit(1)

    output = sys.argv[1]
    inputs = sys.argv[2:]

    for p in inputs:
        if not Path(p).exists():
            print(f"Error: {p} not found")
            sys.exit(1)

    print(f"Merging {len(inputs)} presentations...")
    merge_presentations(output, inputs)
    print("Done.")
