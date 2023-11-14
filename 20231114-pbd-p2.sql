/*Atividade Avaliativa (p2):*/

-- 1. Criando a tabela e importando os dados:
CREATE OR REPLACE TABLE tb_youtubers (
	rank INT PRIMARY KEY,
	youtuber VARCHAR(60),
	subscribers BIGINT,
	video_view BIGINT,
	video_count BIGINT,
	category VARCHAR (40),
	year_started INT
);


