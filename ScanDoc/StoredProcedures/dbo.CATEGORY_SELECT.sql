﻿USE [ScanDoc]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CATEGORY_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CATEGORY_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[CATEGORY_SELECT]
	@SHOW_NULL	BIT = 1,
	@MODE		CHAR(1) = ''
AS
BEGIN
	SET NOCOUNT ON;

	SELECT TP, ID, ID_MASTER, NAME, FULL_NAME
	FROM
		(
			SELECT 2 AS TP, ID, ID_MASTER, NAME, FULL_NAME,
				CASE
					WHEN IS_MEMBER('rl_admin') = 1 THEN 'RW'
					ELSE
						(
							SELECT CASE R WHEN 1 THEN 'R' ELSE '' END + CASE W WHEN 1 THEN 'W' ELSE '' END
							FROM
								dbo.CategoryUsers z
								INNER JOIN dbo.Users y ON z.ID_USER = y.ID
							WHERE z.ID_CATEGORY = a.ID
								AND y.LGN = ORIGINAL_LOGIN()
						)
				END AS MODE
			FROM
				dbo.CategoryView a
		) AS o_O
	WHERE @MODE = '' OR MODE LIKE '%' + @MODE + '%'

	UNION ALL

	SELECT 1 AS TP, NULL, NULL, '[нет]', '[нет]'
	WHERE @SHOW_NULL = 1

	ORDER BY FULL_NAME
END
GO
GRANT EXECUTE ON [dbo].[CATEGORY_SELECT] TO rl_reader;
GRANT EXECUTE ON [dbo].[CATEGORY_SELECT] TO rl_user;
GO