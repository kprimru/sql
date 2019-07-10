USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ORGANIZATION_CALC_EDIT] 
	@id SMALLINT,
	@name VARCHAR(128),
	@org SMALLINT,
	@bankid SMALLINT,
	@acc VARCHAR(50),
	@active BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.OrganizationCalc
	SET ORGC_NAME = @name, 
		ORGC_ID_ORG = @org,
		ORGC_ID_BANK = @bankid,
		ORGC_ACCOUNT = @acc,
		ORGC_ACTIVE = @active
	WHERE ORGC_ID = @id
END
