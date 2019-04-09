USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [IP].[LIST_EXCLUDE]
	@TP		TINYINT,
	@HOST	SMALLINT,
	@DISTR	INT,
	@COMP	TINYINT,
	@NOTE	NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE IP.Lists
	SET UNSET_DATE		=	GETDATE(),
		UNSET_USER		=	ORIGINAL_LOGIN(),
		UNSET_REASON	=	@NOTE
	WHERE ID_HOST = @HOST 
		AND DISTR = @DISTR 
		AND COMP = @COMP 
		AND TP = @TP 
		AND UNSET_DATE IS NULL
END
