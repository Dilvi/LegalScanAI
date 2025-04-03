from natasha import (
    Segmenter,
    MorphVocab,
    NewsEmbedding,
    NewsMorphTagger,
    NewsNERTagger,
    Doc
)

class NERExtractor:
    def __init__(self):
        self.segmenter = Segmenter()
        self.morph_vocab = MorphVocab()
        self.emb = NewsEmbedding()
        self.morph_tagger = NewsMorphTagger(self.emb)
        self.ner_tagger = NewsNERTagger(self.emb)

    def extract_entities(self, text: str):
        doc = Doc(text)
        doc.segment(self.segmenter)
        doc.tag_morph(self.morph_tagger)
        doc.tag_ner(self.ner_tagger)

        entities = []
        for span in doc.spans:
            span.normalize(self.morph_vocab)
            entities.append({
                "type": span.type,
                "text": span.text,
                "normal": span.normal
            })
        return entities
