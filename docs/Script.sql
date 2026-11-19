-- AMPLEX - DDL baseado na DER do controle de estoque
-- MySQL 8.0 / InnoDB / utf8mb4

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

CREATE SCHEMA IF NOT EXISTS `controle_estoque` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `controle_estoque`;

-- -----------------------------------------------------
-- Table `controle_estoque`.`usuario`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `controle_estoque`.`usuario` (
  `id_usuario` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(100) NOT NULL,
  `login` VARCHAR(50) NOT NULL,
  `senha_hash` VARCHAR(255) NOT NULL,
  `perfil` ENUM('ADMIN', 'OPERADOR', 'ESTOQUISTA') NOT NULL,
  `ativo` TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id_usuario`),
  UNIQUE INDEX `uk_usuario_login` (`login` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `controle_estoque`.`fornecedor`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `controle_estoque`.`fornecedor` (
  `id_fornecedor` INT NOT NULL AUTO_INCREMENT,
  `razao_social` VARCHAR(150) NOT NULL,
  `nome_fantasia` VARCHAR(150) NULL DEFAULT NULL,
  `cnpj` VARCHAR(20) NOT NULL,
  `telefone` VARCHAR(20) NULL DEFAULT NULL,
  `email` VARCHAR(150) NULL DEFAULT NULL,
  `ativo` TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id_fornecedor`),
  UNIQUE INDEX `uk_fornecedor_cnpj` (`cnpj` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `controle_estoque`.`categoria`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `controle_estoque`.`categoria` (
  `id_categoria` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(100) NOT NULL,
  `descricao` TEXT NULL DEFAULT NULL,
  `ativo` TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id_categoria`),
  UNIQUE INDEX `uk_categoria_nome` (`nome` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `controle_estoque`.`produto`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `controle_estoque`.`produto` (
  `id_produto` INT NOT NULL AUTO_INCREMENT,
  `id_categoria` INT NOT NULL,
  `sku` VARCHAR(50) NOT NULL,
  `descricao` VARCHAR(150) NOT NULL,
  `marca` VARCHAR(100) NULL DEFAULT NULL,
  `unidade` VARCHAR(20) NOT NULL,
  `preco_custo` DECIMAL(10,2) NOT NULL,
  `preco_venda` DECIMAL(10,2) NOT NULL,
  `saldo_estoque` INT NOT NULL DEFAULT 0,
  `estoque_minimo` INT NOT NULL DEFAULT 0,
  `ativo` TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id_produto`),
  UNIQUE INDEX `uk_produto_sku` (`sku` ASC) VISIBLE,
  INDEX `fk_produto_categoria` (`id_categoria` ASC) VISIBLE,
  CONSTRAINT `fk_produto_categoria`
    FOREIGN KEY (`id_categoria`)
    REFERENCES `controle_estoque`.`categoria` (`id_categoria`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `controle_estoque`.`entrada_estoque`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `controle_estoque`.`entrada_estoque` (
  `id_entrada` INT NOT NULL AUTO_INCREMENT,
  `id_fornecedor` INT NOT NULL,
  `id_usuario` INT NOT NULL,
  `data_entrada` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `numero_documento` VARCHAR(50) NOT NULL,
  `situacao` ENUM('ABERTA', 'CONCLUIDA', 'CANCELADA') NOT NULL,
  PRIMARY KEY (`id_entrada`),
  INDEX `fk_entrada_fornecedor` (`id_fornecedor` ASC) VISIBLE,
  INDEX `fk_entrada_usuario` (`id_usuario` ASC) VISIBLE,
  CONSTRAINT `fk_entrada_fornecedor`
    FOREIGN KEY (`id_fornecedor`)
    REFERENCES `controle_estoque`.`fornecedor` (`id_fornecedor`),
  CONSTRAINT `fk_entrada_usuario`
    FOREIGN KEY (`id_usuario`)
    REFERENCES `controle_estoque`.`usuario` (`id_usuario`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `controle_estoque`.`item_entrada`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `controle_estoque`.`item_entrada` (
  `id_item_entrada` INT NOT NULL AUTO_INCREMENT,
  `id_entrada` INT NOT NULL,
  `id_produto` INT NOT NULL,
  `quantidade` INT NOT NULL,
  `custo_unitario` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`id_item_entrada`),
  INDEX `fk_item_entrada_entrada` (`id_entrada` ASC) VISIBLE,
  INDEX `fk_item_entrada_produto` (`id_produto` ASC) VISIBLE,
  CONSTRAINT `fk_item_entrada_entrada`
    FOREIGN KEY (`id_entrada`)
    REFERENCES `controle_estoque`.`entrada_estoque` (`id_entrada`),
  CONSTRAINT `fk_item_entrada_produto`
    FOREIGN KEY (`id_produto`)
    REFERENCES `controle_estoque`.`produto` (`id_produto`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `controle_estoque`.`saida_estoque`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `controle_estoque`.`saida_estoque` (
  `id_saida` INT NOT NULL AUTO_INCREMENT,
  `id_usuario` INT NOT NULL,
  `data_saida` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `motivo` VARCHAR(255) NOT NULL,
  `situacao` ENUM('ABERTA', 'CONCLUIDA', 'CANCELADA') NOT NULL,
  PRIMARY KEY (`id_saida`),
  INDEX `fk_saida_usuario` (`id_usuario` ASC) VISIBLE,
  CONSTRAINT `fk_saida_usuario`
    FOREIGN KEY (`id_usuario`)
    REFERENCES `controle_estoque`.`usuario` (`id_usuario`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `controle_estoque`.`item_saida`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `controle_estoque`.`item_saida` (
  `id_item_saida` INT NOT NULL AUTO_INCREMENT,
  `id_saida` INT NOT NULL,
  `id_produto` INT NOT NULL,
  `quantidade` INT NOT NULL,
  PRIMARY KEY (`id_item_saida`),
  INDEX `fk_item_saida_saida` (`id_saida` ASC) VISIBLE,
  INDEX `fk_item_saida_produto` (`id_produto` ASC) VISIBLE,
  CONSTRAINT `fk_item_saida_saida`
    FOREIGN KEY (`id_saida`)
    REFERENCES `controle_estoque`.`saida_estoque` (`id_saida`),
  CONSTRAINT `fk_item_saida_produto`
    FOREIGN KEY (`id_produto`)
    REFERENCES `controle_estoque`.`produto` (`id_produto`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `controle_estoque`.`inventario`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `controle_estoque`.`inventario` (
  `id_inventario` INT NOT NULL AUTO_INCREMENT,
  `id_usuario` INT NOT NULL,
  `data_inventario` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `observacao` TEXT NULL DEFAULT NULL,
  `situacao` ENUM('EM_ANDAMENTO', 'CONCLUIDO', 'CANCELADO') NOT NULL,
  PRIMARY KEY (`id_inventario`),
  INDEX `fk_inventario_usuario` (`id_usuario` ASC) VISIBLE,
  CONSTRAINT `fk_inventario_usuario`
    FOREIGN KEY (`id_usuario`)
    REFERENCES `controle_estoque`.`usuario` (`id_usuario`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `controle_estoque`.`item_inventario`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `controle_estoque`.`item_inventario` (
  `id_item_inventario` INT NOT NULL AUTO_INCREMENT,
  `id_inventario` INT NOT NULL,
  `id_produto` INT NOT NULL,
  `saldo_sistema` INT NOT NULL,
  `quantidade_contada` INT NOT NULL,
  `diferenca` INT NOT NULL,
  PRIMARY KEY (`id_item_inventario`),
  INDEX `fk_item_inventario_inventario` (`id_inventario` ASC) VISIBLE,
  INDEX `fk_item_inventario_produto` (`id_produto` ASC) VISIBLE,
  CONSTRAINT `fk_item_inventario_inventario`
    FOREIGN KEY (`id_inventario`)
    REFERENCES `controle_estoque`.`inventario` (`id_inventario`),
  CONSTRAINT `fk_item_inventario_produto`
    FOREIGN KEY (`id_produto`)
    REFERENCES `controle_estoque`.`produto` (`id_produto`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `controle_estoque`.`movimentacao_estoque`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `controle_estoque`.`movimentacao_estoque` (
  `id_movimentacao` INT NOT NULL AUTO_INCREMENT,
  `id_produto` INT NOT NULL,
  `id_usuario` INT NOT NULL,
  `tipo` ENUM('ENTRADA', 'SAIDA', 'AJUSTE_INVENTARIO') NOT NULL,
  `quantidade` INT NOT NULL,
  `saldo_anterior` INT NOT NULL,
  `saldo_posterior` INT NOT NULL,
  `data_hora` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `origem` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`id_movimentacao`),
  INDEX `fk_movimentacao_produto` (`id_produto` ASC) VISIBLE,
  INDEX `fk_movimentacao_usuario` (`id_usuario` ASC) VISIBLE,
  CONSTRAINT `fk_movimentacao_produto`
    FOREIGN KEY (`id_produto`)
    REFERENCES `controle_estoque`.`produto` (`id_produto`),
  CONSTRAINT `fk_movimentacao_usuario`
    FOREIGN KEY (`id_usuario`)
    REFERENCES `controle_estoque`.`usuario` (`id_usuario`))
ENGINE = InnoDB;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
