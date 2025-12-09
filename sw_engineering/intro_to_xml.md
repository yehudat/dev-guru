## XML (eXtensible Markup Language)

XML (eXtensible Markup Language) is a markup language used for storing and transporting data.

### Basic example

Below is a basic XML example with detailed comments explaining all the possible components,
their syntax structures, and names.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!-- This is the XML declaration that defines the version and character encoding of the document. -->

<library> <!-- This is the root element, or root node, of the XML document. It must contain all other elements. -->

    <!-- This is a comment. Comments can be used anywhere within an XML file to describe or document the content. -->

    <book id="1" genre="fiction"> <!-- This is a start tag for the 'book' element. It has two attributes: 'id' and 'genre'. -->
        <title>XML Fundamentals</title> <!-- This is a nested element called 'title', which is a child of 'book'. -->
        <author>John Doe</author> <!-- The 'author' element is another child of the 'book' element. -->
        <published>2021</published> <!-- This element 'published' holds the publication year of the book. -->
        <summary><![CDATA[This is a basic guide to XML syntax, including practical examples.]]></summary>
        <!--
        The 'summary' element includes CDATA. CDATA (Character Data) allows the inclusion of text that should not be parsed by the XML parser.
        Anything inside CDATA is treated as raw text, allowing symbols that would otherwise need escaping.
        -->
    </book> <!-- This is the closing tag for the 'book' element. -->

    <book id="2" genre="non-fiction">
        <title>History of Technology</title>
        <author>Jane Smith</author>
        <published>2019</published>
        <description>
            This book explores the evolution of technology from ancient times to the modern day.
            <note>Recommended for readers who love science.</note>
            <!-- The 'note' element is a nested child element inside 'description'. -->
        </description>
    </book>

    <magazine>
        <title>Science Weekly</title>
        <issue>2022-05</issue>
        <articles>
            <article>Understanding Quantum Physics</article>
            <article>New Discoveries in Space</article>
            <!-- The 'articles' element is a container element, holding multiple 'article' child elements. -->
        </articles>
    </magazine>

</library> <!-- This is the closing tag for the root 'library' element. -->
```

### Breakdown of XML Syntax Components

#### XML Declaration (<?xml ... ?>):

This is usually the first line in an XML document.
It defines the version of XML and the character encoding.

```xml
<?xml version="1.0" encoding="UTF-8"?>
```

#### Root Element

Every XML document must have a single root element that contains all the other elements.
In the example, <library> is the root element.

```xml
<library> ... </library>
```

#### Element (Node)

An XML element is a container for text, other elements, or attributes.
It is represented with a start tag and an end tag.
In the example, <book> is an element with nested children.

```xml
<book> ... </book>
```

#### Attributes

Attributes provide additional information about an element.
They are defined within the start tag.
In the example, the <book> element has id and genre attributes.

```xml
<book id="1" genre="fiction"> ... </book>
```

#### Child Elements

Elements that are nested within another element are called child elements.
For example, <title>, <author>, and <published> are child elements of <book>.

```xml
<book>
    <title>XML Fundamentals</title>
    <author>John Doe</author>
    <published>2021</published>
</book>
```

#### Comments

Comments can be added anywhere in the XML document.
They are ignored by the XML parser.

```xml
<!-- This is a comment -->
```

#### CDATA (<![CDATA[ ... ]]>)

CDATA stands for Character Data and is used to include text that should not be parsed by the XML parser.
It allows special characters without needing to escape them.

```xml
<summary><![CDATA[This is a basic guide to XML syntax, including practical examples.]]></summary>
```

#### Nested Elements

Elements can be nested inside other elements, forming a tree-like structure.
The <description> element contains a nested <note> element.

```xml
<description>
    This book explores the evolution of technology from ancient times to the modern day.
    <note>Recommended for readers who love science.</note>
</description>
```

### Key Points

- __Start Tag__: This marks the beginning of an element, e.g., <title>.
- __End Tag__: This marks the end of an element, e.g., </title>.
- __Self-Closing Tag__: Some tags can be self-closed when they don’t need any content. You would write them like <element />.
- __Attributes__: Key-value pairs within an element that add extra information (id="1").
- __Tree Structure__: XML is naturally hierarchical; elements can be parents, children, or siblings.
