```python
from docx import Document
from docx.document import Document as _Document
from docx.table import Table
from docx.text.paragraph import Paragraph


def iterate_elements(parent):
    """
    Iterate over the block items in the document.
    Returns elements in the order they appear in the document.
    """
    if isinstance(parent, _Document):
        elements = parent.element.body
    else:
        raise ValueError("Parent must be a Document instance.")
    
    for element in elements:
        if element.tag.endswith('tbl'):
            yield Table(element, parent)
        elif element.tag.endswith('p'):
            yield Paragraph(element, parent)


def main():
    # Load the Word document
    doc_path = 'example.docx'  # Replace this with your .docx file path
    document = Document(doc_path)

    # Iterate through the body elements and print them
    for element in iter_block_items(document):
        if isinstance(element, Paragraph):
            print("Paragraph:")
            print(element.text)
            print()
        elif isinstance(element, Table):
            print("Table:")
            for row in element.rows:
                row_text = [cell.text for cell in row.cells]
                print("\t".join(row_text))
            print()


if __name__ == "__main__":
    main()
```