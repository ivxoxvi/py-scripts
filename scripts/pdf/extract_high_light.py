import fitz


def extract_highlights(pdf_path):
    with fitz.open(pdf_path) as doc:
        highlights = []

        for page_num, page in enumerate(doc.pages(), start=1):
            annots = page.annots()
            if not annots:
                continue

            for annot in annots:
                if annot.type[1] == "Highlight":
                    # get the coordinates of the annotation
                    points = annot.vertices
                    if not points:
                        continue
                    # convert the coordinates to a rectangle area
                    rect = fitz.Quad(points).rect
                    # extract the texts in the rectangle
                    text = page.get_textbox(rect).strip()
                    # get the annotation content
                    info = annot.info
                    content = info.get("content", "")

                    highlights.append(
                        {
                            "page": page_num + 1,
                            "text": text,
                            "comment": content,
                            "color": annot.colors.get("fill"),
                        }
                    )
        return highlights


if __name__ == "__main__":
    ROOT = "/Users/vxoxvx/Downloads/朗文9000词（实际7000多）.pdf"

    extracted = extract_highlights(ROOT)
    for item in extracted:
        print(f"第{item['page']}页: {item['text']}")
        if item["comment"]:
            print(f"  注释: {item['comment']}")
