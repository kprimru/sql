USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_1C_GET]
	@CL_ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT CL_1C
	FROM dbo.CLientTable
	WHERE CL_ID = @CL_ID
END
