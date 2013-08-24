#include <grid_operator.h>

QMap<QString, tl::Tile::Type> GridOperator::typeStringMap
= { { "Tile_Line",       tl::Tile::Line },
    { "Tile_Start",      tl::Tile::Start },
    { "Tile_Turn",       tl::Tile::Turn },
    { "Tile_Saw",        tl::Tile::Saw },
    { "Tile_Hill",       tl::Tile::Hill },
    { "Tile_Teeth",      tl::Tile::Teeth },
    { "Tile_Crossing",   tl::Tile::Crossing}
  };

GridOperator::GridOperator(QObject *parent)
    : QObject(parent)
    , m_grid_width(8)
    , m_grid_height(8)
    , m_tile_side(100)
    , m_grid(nullptr)
{
}

int GridOperator::gridWidth()
{
    return m_grid_width;
}

void GridOperator::setGridWidth(int w)
{
    m_grid_width = w;
    gridDimensionChanged();
}

int GridOperator::gridHeight()
{
    return m_grid_height;
}

void GridOperator::setGridHeight(int h)
{
    m_grid_height = h;
    gridDimensionChanged();
}

int GridOperator::tileSide()
{
    return m_tile_side;
}

QQuickItem *GridOperator::grid()
{
    return m_grid;
}

void GridOperator::setGrid(QQuickItem *grid)
{
    m_grid = grid;
    gridChanged();
}

void GridOperator::saveGrid(const QUrl & url)
{
    Q_ASSERT(m_grid);

    tl::TrackModel m (m_grid_width, m_grid_height);
    QVariant p;
    QQuickItem * tile;

    for (QQuickItem * dropArea : m_grid->childItems())
    {
        p = dropArea->property("haveTile");
        if (p.isValid() && p.toBool())
        {
            /*
             * a DropArea's first child is a highlight rectangle; the only
             * other child it ever has is a Tile; therefore, childItems().last()
             * should point us to that Tile
             */
            tile = dropArea->childItems().last();
            m.addTile(tl::Tile(stringToType(tile->objectName()),
                               dropArea->x() / m_tile_side,
                               dropArea->y() / m_tile_side,
                               static_cast<int>(tile->rotation()) % 360));
        }
    }
    tl::io::saveTrackToFile(m, url.toLocalFile().toStdString());
}

void GridOperator::loadGrid(const QUrl & url)
{
    Q_ASSERT(m_grid);

    tl::TrackModel m;
    if (!tl::io::populateTrackFromFile(m, url.toLocalFile().toStdString()))
        return;
    m_grid_height = m.height();
    m_grid_width = m.width();
    gridDimensionChanged();
    for (const tl::Tile & t : m.tiles())
        placeTile(t.x(), t.y(), t.rotation(), typeToString(t.type()));
}

tl::Tile::Type GridOperator::stringToType(const QString & string)
{
    return typeStringMap.value(string, tl::Tile::Invalid);
}

QString GridOperator::typeToString(tl::Tile::Type type)
{
    return typeStringMap.key(type);
}
