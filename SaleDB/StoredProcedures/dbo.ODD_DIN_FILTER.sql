USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ODD_DIN_FILTER]
	@DISTR		INT				=	NULL,
	@SYS		NVARCHAR(10)	=	NULL,
	@ACTIVE		BIT				=	NULL
AS
	SELECT	
		SystemShortName,
		DistrNumber,
		Complect,
		RegisterDate,
		DS_INDEX,
		RPR_OPER
	FROM [PC275-SQL\ALPHA].[ClientDB].[Reg].[RegNodeSearchView] AS R  WITH(NOEXPAND)
	OUTER APPLY
	(
		SELECT TOP (1) P.RPR_OPER
		FROM [PC275-SQL\ALPHA].[ClientDB].[dbo].[RegProtocol] AS P
		WHERE P.RPR_ID_HOST = R.HostId
			AND P.RPR_DISTR = R.DistrNumber
			AND P.RPR_COMP = R.CompNumber
			AND RPR_OPER LIKE 'Изменен email%'
		ORDER BY RPR_DATE DESC
	) AS P
	WHERE	R.SST_SHORT='ОДД'
		AND NT_SHORT='ОВП'
		AND (CAST(DistrNumber AS NVARCHAR) LIKE '%'+CAST(@DISTR AS NVARCHAR)+'%' OR @DISTR IS NULL)
		AND (SystemShortName LIKE '%'+@SYS+'%' OR @SYS IS NULL)
		AND (DS_INDEX = @ACTIVE OR @ACTIVE IS NULL)
	ORDER BY DS_INDEX, SystemShortName