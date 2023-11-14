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


-- 3. Criando a coluna "Ativo" a partir de ALTER TABLE:
ALTER TABLE tb_youtubers
ADD COLUMN ativo INT DEFAULT 1 CHECK (ativo IN (0, 1));

SELECT * FROM tb_youtubers;


-- 4. Criação da tabela de log:
CREATE TABLE OR REPLACE tb_log_youtubers (
  id_log SERIAL PRIMARY KEY,
  nome_youtuber VARCHAR(60),
  categoria_canal VARCHAR(40),
  ano_inicio INT,
  data_registro TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
	
);
 
-- Trigger para registrar log antes de inserção ou atualização na tabela principal
CREATE OR REPLACE FUNCTION fn_log_antes_de_inserir_atualizar() RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  -- Insere um registro de log antes de cada operação de inserção ou atualização
  INSERT INTO tb_log_youtubers (nome_youtuber, categoria_canal, ano_inicio)
  VALUES (NEW.youtuber, NEW.category, NEW.year_started);
  RETURN NEW;
END;
$$;
 
-- Trigger associada à tabela principal (tb_youtubers)
CREATE OR REPLACE TRIGGER tg_log_antes_de_inserir_atualizar
BEFORE INSERT OR UPDATE ON tb_youtubers
FOR EACH ROW
EXECUTE FUNCTION fn_log_antes_de_inserir_atualizar();
 
--select * from tb_log_youtubers;

--INSERT INTO tb_youtubers VALUES (530,'Lucas Neto', 100000, 10000, 10000, 'fun', 2005);


-- 5. Trigger (feat(tg): dados valiosos):
CREATE OR REPLACE FUNCTION fn_antes_do_delete()
RETURNS TRIGGER AS $$
BEGIN
	RAISE NOTICE '%', OLD;
    -- Insere os dados na tabela de logs antes da exclusão
    UPDATE tb_youtubers SET ativo=0 WHERE rank=OLD.rank;
	INSERT INTO tb_log_youtubers (nome_youtuber, categoria_canal, ano_inicio)
    VALUES (OLD.youtuber, OLD.category, OLD.year_started);
    -- Impede a exclusão dos dados
    --RAISE EXCEPTION 'Não é permitido excluir dados da tabela tb_youtubers.';
    -- Retorna OLD para indicar que a operação de exclusão foi interrompida
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Trigger associado à tabela tb_youtubers
CREATE OR REPLACE TRIGGER tg_antes_do_delete
AFTER DELETE ON tb_youtubers
FOR EACH ROW
EXECUTE FUNCTION fn_antes_do_delete();
 
UPDATE tb_youtubers SET ativo=0 WHERE rank=2; 
SELECT * FROM tb_youtubers ORDER BY rank ASC;
  
DELETE FROM tb_youtubers WHERE rank =3;

SELECT * FROM tb_log_youtubers;