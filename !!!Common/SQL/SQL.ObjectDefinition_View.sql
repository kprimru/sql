/****** Object:  UserDefinedFunction [SQL].[ObjectDefinition?View]    Script Date: 11.09.2022 0:56:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER FUNCTION [SQL].[ObjectDefinition?View]
(
    @Object_Id      Int
)
RETURNS NVarChar(Max)
AS
BEGIN
    DECLARE @Result NVarChar(Max);

    SET @Result = Object_Definition(@Object_Id);

    SET @Result = @Result + IsNull('
GO
' + [SQL].[ObjectDefinition?Indexes](@Object_Id) + '
', '');

    RETURN @Result;
END;
GO