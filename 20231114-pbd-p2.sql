/*Atividade Avaliativa (p2):*/
DROP TABLE tb_youtubers CASCADE;
CREATE TABLE tb_youtubers (
	rank INT PRIMARY KEY,
	youtuber VARCHAR(60),
	subscribers BIGINT,
	video_view BIGINT,
	video_count BIGINT,
	category VARCHAR (40),
	year_started INT
);

