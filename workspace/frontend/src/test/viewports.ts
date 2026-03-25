export type TestViewport = {
  name: string;
  width: number;
  height: number;
};

export const webMobileViewport: TestViewport = {
  name: 'web-mobile',
  width: 360,
  height: 800,
};

export const webDesktopViewport: TestViewport = {
  name: 'web-desktop',
  width: 1280,
  height: 960,
};

export async function withViewport<T>(
  viewport: TestViewport,
  run: () => Promise<T>,
): Promise<T> {
  const previous = {
    innerWidth: window.innerWidth,
    innerHeight: window.innerHeight,
    outerWidth: window.outerWidth,
    outerHeight: window.outerHeight,
  };

  setViewport(viewport);

  try {
    return await run();
  } finally {
    restoreViewport(previous);
  }
}

function setViewport(viewport: TestViewport) {
  defineWindowDimension('innerWidth', viewport.width);
  defineWindowDimension('innerHeight', viewport.height);
  defineWindowDimension('outerWidth', viewport.width);
  defineWindowDimension('outerHeight', viewport.height);
  window.dispatchEvent(new Event('resize'));
}

function restoreViewport(previous: {
  innerWidth: number;
  innerHeight: number;
  outerWidth: number;
  outerHeight: number;
}) {
  defineWindowDimension('innerWidth', previous.innerWidth);
  defineWindowDimension('innerHeight', previous.innerHeight);
  defineWindowDimension('outerWidth', previous.outerWidth);
  defineWindowDimension('outerHeight', previous.outerHeight);
  window.dispatchEvent(new Event('resize'));
}

function defineWindowDimension(
  property: 'innerWidth' | 'innerHeight' | 'outerWidth' | 'outerHeight',
  value: number,
) {
  Object.defineProperty(window, property, {
    configurable: true,
    writable: true,
    value,
  });
}
