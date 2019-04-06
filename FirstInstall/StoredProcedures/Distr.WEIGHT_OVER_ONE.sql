USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Distr].[WEIGHT_OVER_ONE] 
	@IDLIST UNIQUEIDENTIFIER,
	@DATE SMALLDATETIME,
	@RC INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @MASTERID UNIQUEIDENTIFIER

	SELECT @MASTERID = WG_ID_MASTER
	FROM Distr.WeightDetail
	WHERE WG_ID = @IDLIST

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)

	EXEC Common.PROTOCOL_VALUE_GET 'WEIGHT', @MASTERID, @OLD OUTPUT
	
	
	UPDATE	Distr.WeightDetail
	SET		WG_END	=	@DATE,
			WG_REF	=	3
	WHERE	WG_ID	=	@IDLIST
	
	
	EXEC Common.PROTOCOL_VALUE_GET 'WEIGHT', NULL, @NEW OUTPUT

	EXEC Common.PROTOCOL_INSERT 'WEIGHT', '��������', @MASTERID, @OLD, @NEW

END

