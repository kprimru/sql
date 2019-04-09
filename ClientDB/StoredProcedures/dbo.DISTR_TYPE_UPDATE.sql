USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DISTR_TYPE_UPDATE]
	@ID	INT,
	@NAME	VARCHAR(50),
	@SHORT	VARCHAR(10),
	@ORDER	INT,
	@FULL	NVARCHAR(50),
	@CHECK	BIT
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.DistrTypeTable
	SET DistrTypeName = @NAME,
		DistrTypeShortName = @SHORT,
		DistrTypeOrder = @ORDER,
		DistrTypeFull = @FULL,
		DistrTypeBaseCheck = @CHECK,
		DistrTypeLast = GETDATE()
	WHERE DistrTypeID = @ID
END