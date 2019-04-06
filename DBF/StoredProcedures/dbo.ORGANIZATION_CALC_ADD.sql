USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ORGANIZATION_CALC_ADD] 
	@name	varchar(128),
	@org	smallint,
	@bank SMALLINT,
	@acc VARCHAR(64),
	@active BIT = 1,
	@returnvalue BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO dbo.OrganizationCalc
		(
			ORGC_NAME, ORGC_ID_ORG, ORGC_ID_BANK, ORGC_ACCOUNT, ORGC_ACTIVE
		) 
	VALUES 
		(
			@name, @org, @bank, @acc, @active
		)

	IF @returnvalue = 1
		SELECT SCOPE_IDENTITY() AS NEW_IDEN

	SET NOCOUNT OFF
END
