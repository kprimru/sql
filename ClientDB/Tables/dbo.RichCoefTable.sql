USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RichCoefTable]
(
        [RichCoefID]      Int     Identity(1,1)   NOT NULL,
        [RichCoefStart]   Int                     NOT NULL,
        [RichCoefEnd]     Int                     NOT NULL,
        [RichCoefVal]     float                   NOT NULL,
        CONSTRAINT [PK_dbo.RichCoefTable] PRIMARY KEY CLUSTERED ([RichCoefID])
);
GO
