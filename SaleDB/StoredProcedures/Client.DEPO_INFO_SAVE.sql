﻿USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Client].[DEPO_INFO_SAVE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Client].[DEPO_INFO_SAVE]  AS SELECT 1')
GO
ALTER PROCEDURE [Client].[DEPO_INFO_SAVE]
	@COMPANY_NUMBER	INT,
	@NAME		NVARCHAR(200),
	@INN		NVARCHAR(20),
	@REGION		NVARCHAR(30),
	@CITY		NVARCHAR(50),
	@ADDRESS	NVARCHAR(200),
	@FIO1		NVARCHAR(200),
	@PHONE1		NVARCHAR(12),
	@FIO2		NVARCHAR(200),
	@PHONE2		NVARCHAR(12),
	@RIVAL		INT
AS
BEGIN
	IF EXISTS
		(
			SELECT ID
			FROM Client.DEPOInfo
			WHERE COMPANY_NUMBER = @COMPANY_NUMBER
		)
		UPDATE
			Client.DEPOInfo
		SET
			NAME = @NAME,
			INN = @INN,
			REGION = @REGION,
			CITY = @CITY,
			ADDRESS = @ADDRESS,
			FIO1 = @FIO1,
			PHONE1 = @PHONE1,
			FIO2 = @FIO2,
			PHONE2 = @PHONE2,
			RIVAL = @RIVAL
		WHERE
			COMPANY_NUMBER = @COMPANY_NUMBER
	ELSE
		INSERT INTO Client.DEPOInfo(NAME, INN, REGION, CITY, ADDRESS, FIO1, PHONE1, FIO2, PHONE2, RIVAL, COMPANY_NUMBER)
		VALUES(@NAME, @INN, @REGION, @CITY, @ADDRESS, @FIO1, @PHONE1, @FIO2, @PHONE2, @RIVAL, @COMPANY_NUMBER)
END
GO
GRANT EXECUTE ON [Client].[DEPO_INFO_SAVE] TO rl_depo_info_u;
GO
