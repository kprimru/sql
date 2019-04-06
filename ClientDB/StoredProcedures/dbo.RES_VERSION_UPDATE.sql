USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[RES_VERSION_UPDATE]
	@ID	INT,
	@NUMBER	VARCHAR(100),
	@LATEST	BIT,
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.ResVersionTable
	SET ResVersionNumber = @NUMBER,
		ResVersionBegin = @BEGIN,
		ResVersionEnd = @END,
		IsLatest = @LATEST,
		ResVersionLast = GETDATE()
	WHERE ResVersionID = @ID
END