USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Client].[COMPANY_DELIVERY_SAVE]
	@ID			UNIQUEIDENTIFIER OUTPUT,
	@COMPANY	UNIQUEIDENTIFIER,
	@FIO		NVARCHAR(256),
	@POS		NVARCHAR(256),
	@EMAIL		NVARCHAR(256),
	@DATE		SMALLDATETIME,
	@PLAN_DATE	SMALLDATETIME,
	@OFFER		NVARCHAR(256),
	@STATE		SMALLINT
AS
BEGIN
	SET NOCOUNT ON;

	IF @ID IS NULL
		INSERT INTO Client.CompanyDelivery(ID_COMPANY, FIO, POS, EMAIL, DATE, PLAN_DATE, OFFER, STATE)
			VALUES(@COMPANY, @FIO, @POS, @EMAIL, @DATE, @PLAN_DATE, @OFFER, @STATE)
	ELSE
		UPDATE Client.CompanyDelivery
		SET FIO			=	@FIO,
			POS			=	@POS,
			EMAIL		=	@EMAIL,
			DATE		=	@DATE,
			PLAN_DATE	=	@PLAN_DATE,
			OFFER		=	@OFFER,
			STATE		=	@STATE
		WHERE ID = @ID
END
