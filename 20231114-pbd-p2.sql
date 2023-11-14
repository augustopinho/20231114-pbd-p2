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

--SELECT * FROM tb_youtubers;

-- 2. Criando o Trigger ( valores negativos jamais):

-- Criando função base:
CREATE OR REPLACE FUNCTION fn_antes_de_insert_update() RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  campo_name TEXT;
  valor_numerico NUMERIC;
BEGIN
  -- Loop através dos campos da tabela
   FOR campo_name IN (SELECT column_name FROM information_schema.columns WHERE table_name = 'tb_youtubers' AND (data_type = 'integer' OR data_type = 'bigint'))  
  LOOP
    -- Constrói a expressão dinâmica e armazena o resultado em uma variável
    EXECUTE 'SELECT $1."' || campo_name || '"' INTO valor_numerico USING NEW;
 
    -- Verifica se o valor do campo é negativo
    IF valor_numerico < 0 THEN
      RAISE EXCEPTION 'Não é permitido inserir ou atualizar com valores negativos em campos numéricos.';
    END IF;
  END LOOP;
 
  -- Se chegou até aqui, retorna NEW para permitir a operação
  RETURN NEW;
END;
$$;
 
-- Trigger associado à tabela tb_youtubers
CREATE OR REPLACE TRIGGER tg_antes_do_insert_update
BEFORE INSERT OR UPDATE ON tb_youtubers
FOR EACH ROW
EXECUTE FUNCTION fn_antes_de_insert_update();

--INSERT INTO tb_youtubers VALUES (529,'Lucas Neto', -100000, 10000, 10000, 'fun', 2005);
