USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DISTR_TYPE_UPDATE]
	@ID	INT,
	@NAME	VARCHAR(50),
	@ORDER	INT,
	@FULL	NVARCHAR(50),
	@CHECK	BIT,
	@Code	VarChar(100)
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.DistrTypeTable
	SET DistrTypeName = @NAME,
		DistrTypeOrder = @ORDER,
		DistrTypeFull = @FULL,
		DistrTypeCode = @Code,
		DistrTypeBaseCheck = @CHECK
	WHERE DistrTypeID = @ID
END
