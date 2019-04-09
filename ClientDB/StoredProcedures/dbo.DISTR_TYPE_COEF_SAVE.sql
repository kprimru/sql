USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DISTR_TYPE_COEF_SAVE]
	@NET	INT,
	@PERIOD	UNIQUEIDENTIFIER,
	@COEF	DECIMAL(8, 4),
	@WEIGHT	DECIMAL(8, 4),
	@RND	SMALLINT,
	@NEXT	BIT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @PR_DATE SMALLDATETIME
	
	SELECT @PR_DATE = START
	FROM Common.Period
	WHERE ID = @PERIOD
	
	UPDATE a
	SET COEF = @COEF,
		WEIGHT = @WEIGHT,
		RND = @RND
	FROM
		dbo.DistrTypeCoef a
		INNER JOIN Common.Period b ON a.ID_MONTH = b.ID
	WHERE a.ID_NET = @NET
		AND (b.ID = @PERIOD OR b.START > @PR_DATE AND @NEXT = 1)
		
	INSERT INTO dbo.DistrTypeCoef(ID_NET, ID_MONTH, COEF, WEIGHT, RND)
		SELECT @NET, ID, @COEF, @WEIGHT, @RND
		FROM Common.Period a
		WHERE (a.ID = @PERIOD OR a.START > @PR_DATE AND @NEXT = 1)
			AND TYPE = 2
			AND NOT EXISTS
				(
					SELECT *
					FROM dbo.DistrTypeCoef z
					WHERE z.ID_NET = @NET
						AND z.ID_MONTH = a.ID
				)
END
