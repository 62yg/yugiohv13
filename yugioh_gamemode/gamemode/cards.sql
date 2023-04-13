CREATE TABLE IF NOT EXISTS cards (
    card_id INTEGER PRIMARY KEY,
    card_name TEXT NOT NULL,
    card_type TEXT NOT NULL,
    card_desc TEXT NOT NULL
);

INSERT INTO cards (card_id, card_name, card_type, card_desc)
VALUES (1, 'Dark Magician', 'Monster', 'The ultimate wizard in terms of attack and defense.');

INSERT INTO cards (card_id, card_name, card_type, card_desc)
VALUES (2, 'Blue-Eyes White Dragon', 'Monster', 'This legendary dragon is a powerful engine of destruction.');
