USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Price].[PRICE_INSERT]
	@MONTH	UNIQUEIDENTIFIER,
	@SYSTEM	INT,
	@PRICE	MONEY
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO Price.SystemPrice(ID_MONTH, ID_SYSTEM, PRICE)
		SELECT @MONTH, @SYSTEM, @PRICE
		WHERE NOT EXISTS
			(
				SELECT *
				FROM Price.SystemPrice
				WHERE ID_SYSTEM = @SYSTEM AND ID_MONTH = @MONTH
			)
END
